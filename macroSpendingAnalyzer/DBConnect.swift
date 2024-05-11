//
//  DBConnect.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva on 3/31/24.
//

import Foundation
import SQLite


class DBConnect {
    private var db: Connection?
    
    // Purchase
    private var id  = Expression<Int64>("id")
    private var date = Expression<Date>("date")
    private var business = Expression<String>("business")
    private var category =  Expression <String>("category")
    private var product = Expression <String>("product")
    private var total = Expression <Double>("total")
    
    //Income
    private var startDate = Expression<Date>("startDate")
    private var updatedDate = Expression<Date>("updatedDate")
    private var endDate = Expression<Date>("endDate")
    
    // Monthly Expences
    
    // Tables
    private var purchases = Table("purchases")
    private var incomeTable = Table("income")
    
    static let sharedInstance = DBConnect()
    
    // Create new database or establish connection using app documents directory
    init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            
            self.db = try Connection("\(path)/db.sqlite3")
            createPurchaseTable()
            createIncomeTable()
            insertPurchase(business: "trader Joes", category: "food", total: 5.6, date: Date.now)
            insertIncome(startDate: Date.distantPast, updatedDate: Date.now, endDate: Date.distantFuture, business: "Walgreens", total: 500.00)
           // insertPurchase(business: "trader Joes", category: "food", product: "rice", total: 5.6, date: Date.now)
            print("Connection established")
        } catch {
            print(error)
        }
    }
    
    func printAllPurchases() {
        guard let db = db else { return }

        do {
            let allRows = try db.prepare(purchases)
            for row in allRows {
                print("Purchase ID: \(row[id]), Business: \(row[business]), Category: \(row[category]), Total: \(row[total]), Date: \(row[date])")
            }
        } catch {
            print("Failed to fetch purchases: \(error)")
        }
    }

    
    
    func createPurchaseTable() {
        guard let db = db else {return}
        do{
            // TODO check that the table hasn't already been created
            try db.run(purchases.create(ifNotExists : true) {p in
                p.column(id, primaryKey: .autoincrement)
                p.column(business)
                p.column(category)
                p.column(total)
                p.column(date)
            })
        }catch {
            print(error)
        }
        print("purchase table created")
    }


    func createIncomeTable() {
        guard let db = db else {return}
        
        do {
            try db.run(incomeTable.create(ifNotExists : true) {i in
                i.column(id, primaryKey: .autoincrement)
                i.column(startDate)
                i.column(updatedDate)
                i.column(endDate)
                i.column(business)
                i.column(total)
            })
        }catch {
            print(error)
        }
        print("income table created")
    }
    
    func insertIncome(startDate: Date, updatedDate: Date, endDate: Date, business: String, total: Double) {
        guard let db = db else {return}
        let insert = incomeTable.insert(
            self.startDate <- startDate,
            self.updatedDate <- updatedDate,
            self.endDate <- endDate,
            self.business <- business,
            self.total <- total)
        do {
            let insertRow = try db.run(insert)
            print("income inserted successfully to row \(insertRow).")
        } catch {
            print("Error inserting purchase: \(error)")
        }
    }

    

    
    // Function to insert a purchase record
    func insertPurchase(business: String, category: String, total: Double, date: Date) {
        guard let db = db else {return}
        let insert = purchases.insert(
            self.business <- business,
            self.category <- category,
            self.total <- total,
            self.date <- date
                    )
        
        do {
            let insertRow = try db.run(insert)
            print("Purchase inserted successfully to row \(insertRow).")
        } catch {
            print("Error inserting purchase: \(error)")
        }
    }

    func getPurchase() -> [receipt] {
    var recipts: [receipt] = []
        purchases = purchases.order(id.desc)
        guard let db = db else { return [] }
        do {
            for row in try db.prepare(purchases){
                
                    // Process apurchase
                    let purchase = receipt(
                        id: try row.get(id),
                        date: try row.get(date),
                        business: try row.get(business),
                        category: try row.get(category),
                        total: try row.get(total)
                        
                    )
                    
                    
                    recipts.append(purchase)
                }
                print(recipts)
                return recipts
            
        } catch {
            print("Error fetching purchase: \(error)")
        }
        // need to fix this
        return recipts
    }
    
    func getIncome() -> [income] {
        var allIncome: [income] = []
        incomeTable = incomeTable.order(id.desc)
        guard let db = db else { return [] }
        do {
            for row in try db.prepare(incomeTable){
                
                    // Process apurchase
                    let income = income(
                        id: try row.get(id),
                        startDate: try row.get(startDate),
                        updatedDate: try row.get(updatedDate),
                        endDate: try row.get(endDate),
                        business: try row.get(business),
                        total: try row.get(total)
                    )
                    allIncome.append(income)
                }
                print(allIncome)
                return allIncome
            
        } catch {
            print("Error fetching all inocme: \(error)")
        }
        // need to fix this
        return allIncome
    }
    
    func removeIncome(incomeID: Int64){
        guard let db = db else {return}
        do {
            let incomeToRemove = incomeTable.filter(id == incomeID)
            if try db.run(incomeToRemove.delete()) > 0 {
                print("Income with ID \(incomeID) removed successfully.")
            } else {
                print("Income with ID \(incomeID) not found.")
            }
        } catch {
            print("Error removing purchase: \(error)")
        }
    }
    
    func removePurchase(purchaseID: Int64) {
        guard let db = db else {return}
        do {
            let purchaseToDelete = purchases.filter(id == purchaseID)
            if try db.run(purchaseToDelete.delete()) > 0 {
                print("Purchase with ID \(purchaseID) removed successfully.")
            } else {
                print("Purchase with ID \(purchaseID) not found.")
            }
        } catch {
            print("Error removing purchase: \(error)")
        }
    }
    
}
