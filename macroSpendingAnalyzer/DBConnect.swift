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
    
    
    private var id  = Expression<Int64>("id")
    private var date = Expression<Date>("date")
    private var business = Expression<String>("business")
    private var category =  Expression <String>("category")
    private var product = Expression <String>("product")
    private var total = Expression <Double>("total")
    
    private var startDate = Expression<Date>("startDate")
    private var updatedDate = Expression<Date>("updatedDate")
    private var endDate = Expression<Date>("endDate")
    private var accountBalance = Expression <Double>("balance")
    
    // Monthly Expences
    
    // Tables
    private var purchases = Table("purchases")
    private var incomeTable = Table("income")
    private var balanceTable = Table("balance")
    private var monthlyExpencesTable = Table("monthlyExpences")
    
    // number of tables in database
    // Add one for sqlite_sequence table
    let numberOfTables: Int = 4
    static let sharedInstance = DBConnect()
    
    // Create new database or establish connection using app documents directory
    init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            self.db = try Connection("\(path)/db.sqlite3")
            createTables()
            print("Connection established")
        } catch {
            print(error)
        }
    }
    
    func createTables() {
        guard let db = db else { return }
        do{
        let tableCount = try db.scalar("SELECT count(*) FROM sqlite_master WHERE type = 'table'") as! Int64
            print("The current number of tables, tables = \(tableCount)")
            if tableCount == numberOfTables {
                print("tables have been created.")
            } else {
                createPurchaseTable()
                createIncomeTable()
                createBalanceTable()
                insertTestingValues()
            }
        } catch {
            print("Error: \(error)")
        }
        //printTable()
    }
    
    func printTable(){
        guard let db = db else { return }
        do {
            // 1. Connect to the database

            // 2. Define the query to select table names from sqlite_master
            let query = "SELECT name FROM sqlite_master WHERE type = 'table'"

            // 3. Prepare the query
            for table in try db.prepare(query) {
                // 4. Extract the name of each table and print it
                if let tableName = table[0] as? String {
                    print(tableName)
                }
            }
        } catch {
            // 5. Handle any errors
            print("An error occurred: \(error)")
        }
    }
    
    func insertTestingValues() {
        guard let db = db else { return }
        do{
            let pCount = try db.scalar("SELECT COUNT(*) FROM purchases") as! Int64
            let iCount = try db.scalar("SELECT COUNT(*) FROM income") as! Int64
            let bCount = try db.scalar("SELECT COUNT(*) FROM balance") as! Int64
           // let meCount = try db.scalar("SELECT COUNT(*) FROM monthlyExpences") as! Int64
            
            if pCount == 0 {
                insertPurchase(business: "trader Joes", category: "food", total: 5.6, date: Date.now)
                print("Added testing purchases.")
            }
            
            if iCount == 0 {
                insertIncome(startDate: Date.distantPast, updatedDate: Date.now, endDate: Date.distantFuture, business: "Walgreens", total: 500.00)
                print(" Added testing income.")
            }
            
            if bCount == 0 {
                insertBalance(startDate: Date.distantPast, updatedDate: Date.distantPast, accountBalance: 10000)
                print(" Added testing balance.")
            }
//            
//            if meCount == 0 {
//                
//                print(" Added testing monthlyExpences")
//            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
//    func checkBalance(){
//        guard let db = db else { return }
//        let tableName = "balance"
//
//        do {
//            let count = try db.scalar("SELECT COUNT(*) FROM \(tableName)") as! Int64
//            
//            if count == 0 {
//                print("\(tableName) is empty.")
//            } else {
//                print("\(tableName) is not empty. It has \(count) rows.") }
//        } catch {
//            print("Error: \(error)")
//        }
//    }
//    
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

    func createBalanceTable() {
        guard let db = db else {return}
        do{
            // TODO check that the table hasn't already been created
            try db.run(balanceTable.create(ifNotExists : true) {b in
                b.column(id,primaryKey: true)
                b.column(startDate)
                b.column(updatedDate)
                b.column(accountBalance)
            })
        }catch {
            print(error)
        }
        print("balance table created")
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
            print("Error inserting income: \(error)")
        }
    }

    func insertBalance(startDate: Date, updatedDate: Date, accountBalance: Double){
        guard let db = db else {return}

        let newBalance = balanceTable.insert(
            self.id <- 1,
            self.startDate <- startDate,
            self.updatedDate <- updatedDate,
            self.accountBalance <- accountBalance)
        do {
           // let count = try db.scalar("SELECT COUNT(*) FROM balance") as! Int64
            let insertRow = try db.run(newBalance)
            print("Balance edited successfully to row \(insertRow).")
        } catch {
            print("Error editing balance: \(error)")
        }
    }
    
    // need this for update let sum = try db.scalar(users.select(balance.sum))
    func changeBalance(startDate: Date, updatedDate: Date, accountBalance: Double){
        guard let db = db else {return}
        do {
            let acctBalance = balanceTable.filter(id == 1)
            
            try db.run(acctBalance.update(
                self.startDate <- startDate,
                self.updatedDate <- updatedDate,
                self.accountBalance <- accountBalance
            ))
            print("Balance was changed correctly")
        } catch {
            print("Error editing balance: \(error)")
        }
    }
    
    func updateBalance(){
        guard let db = db else {return}
        do {
            if let balance = try db.pluck(balanceTable) {
                let currentAccountBalance = balance[accountBalance]
                let balanceStartDate = balance[startDate]
                let currentDate = balance[updatedDate]
                let purchasesTotal = try db.scalar(purchases.filter(date >= balanceStartDate && date <= currentDate).select(total.sum)) ?? 0.0
                let newBalance = currentAccountBalance - purchasesTotal

                try db.run(balanceTable.update(accountBalance <- newBalance, updatedDate <- currentDate))

                print("Balance updated successfully. New balance: \(newBalance)")
            } else {
                print("No balance found. Initialize the balanceTable.")
            }
        } catch {
            print("Error updating balance: \(error)")
        }
    }
    
    func applyMonthlyIncome() {
        
    }
    
    func applyPurchases() {
        
    }
    
    func applymonthlySExpences() {
        
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
