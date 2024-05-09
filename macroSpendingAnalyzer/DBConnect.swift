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
    let id  = Expression<Int64>("id")
    let date = Expression<Date>("date")
    let business = Expression<String>("business")
    let category =  Expression <String>("category")
    let total = Expression <Double>("total")
    
    private var purchases = Table("purchases")
    private var income = Table("income")
    
    static let sharedinstence = DBConnect()
    // Create new database or establish connection using app documents directory
    
    init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            self.db = try Connection("\(path)/db.sqlite3")
            
            createPurchaseTable() // Create or recreate the table at startup
            
            print("Connection established")
        } catch {
            print("Database connection error: \(error)")
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
        guard let db = db else { return }

        do {
            // Check if the table already exists
            if !(try db.scalar(purchases.exists)) {
                // Create the table if it does not exist
                try db.run(purchases.create { t in
                    t.column(id, primaryKey: .autoincrement)
                    t.column(business)
                    t.column(category)
                    t.column(total)
                    t.column(date)
                })
                print("Purchase table created")
            } else {
                print("Purchase table already exists")
            }
        } catch {
            print("Error checking or creating table: \(error)")
        }
    }


    
//    func createIncomeTable() {
//        guard let db = db else {return}
//        
//        
//    }
    
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

    func getPurchase() -> [Receipt] {
    var recipts: [Receipt] = []
        purchases = purchases.order(id.desc)
        guard let db = db else { return [] }
        do {
            for row in try db.prepare(purchases){
                
                    // Process apurchase
                    let purchase = Receipt(
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
        return recipts
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
