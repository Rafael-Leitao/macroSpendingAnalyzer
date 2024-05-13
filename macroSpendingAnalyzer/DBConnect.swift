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
    
    
    // Tables
    private var purchases = Table("purchases")
    private var depositsTable = Table("deposits")
    private var monthlyIncomeTable = Table("income")
    private var balanceTable = Table("balance")
    private var monthlyExpensesTable = Table("Expenses")
    
    // number of tables in database including one for sqlite_sequence table
    let numberOfTables: Int = 6
    static let sharedInstance = DBConnect()
    
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
            if tableCount == numberOfTables {
                updateMonthlyExpenses()
                updateMonthlyIncome()
                updateBalance()
        
            } else {
                createPurchaseTable()
                createIncomeTable()
                createBalanceTable()
                createDepositsTable()
                createExpensesTable()
                
                
                insertTestingValues()
                updateMonthlyExpenses()
                updateMonthlyIncome()
                updateBalance()
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func insertTestingValues() {
        guard let db = db else { return }
        do{
            let purchaseCount = try db.scalar("SELECT COUNT(*) FROM purchases") as! Int64
            let incomeCount = try db.scalar("SELECT COUNT(*) FROM income") as! Int64
            let balanceCount = try db.scalar("SELECT COUNT(*) FROM balance") as! Int64
            let expensesCount = try db.scalar("SELECT COUNT(*) FROM Expenses") as! Int64
            let depositsCount = try db.scalar("SELECT COUNT(*) FROM deposits") as! Int64
            // let meCount = try db.scalar("SELECT COUNT(*) FROM monthlyExpences") as! Int64
            let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "yyyy-MM-dd"
             
             // Define the date range
             let startDateA = dateFormatter.date(from: "2023-01-01")!
            let startDateB  = dateFormatter.date(from: "2022-01-01")!
            
            if purchaseCount == 0 {
                insertPurchase(business: "trader Joes", category: "food", total: 5.6, date: Date.now)
                print("Added testing data purchases.")
            }
            
            if incomeCount == 0 {
                insertIncome(startDate: startDateA, business: "Walgreens", total: 500.00)
                insertIncome(startDate: startDateA, business: "Burgerking", total: 1000.00)
                print(" Added testing data income.")
            }
            
            if balanceCount == 0 {
                insertBalance(startDate: startDateB, accountBalance: 10000)
                print(" Added testing data balance.")
            }
            
            if expensesCount == 0 {
                insertExpense(startDate: startDateA, business: "att", category: "cable", total: 400.00)
                print(" Added testing data monthlyExpences")
            }
            
            if depositsCount == 0 {
                insertDeposit(depositDate: Date.distantPast, business: "google", total: 4000.00)
                print(" Added testing data monthlyExpences")
            }

            
        } catch {
            print("Error: \(error)")
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
    
    func createExpensesTable() {
        guard let db = db else {return}
        do{
            try db.run(monthlyExpensesTable.create(ifNotExists : true) {p in
                p.column(id, primaryKey: .autoincrement)
                p.column(startDate)
                p.column(updatedDate)
                p.column(business)
                p.column(category)
                p.column(total)
            })
        }catch {
            print(error)
        }
        print("Monthy Expenses table created")
        
    }
    
    func createPurchaseTable() {
        guard let db = db else {return}
        do{
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
            try db.run(monthlyIncomeTable.create(ifNotExists : true) {i in
                i.column(id, primaryKey: .autoincrement)
                i.column(startDate)
                i.column(updatedDate)
                i.column(business)
                i.column(total)
            })
        }catch {
            print(error)
        }
        print("income table created")
    }
    
    func createDepositsTable() {
        guard let db = db else {return}
        
        do {
            try db.run(depositsTable.create(ifNotExists : true) {i in
                i.column(id, primaryKey: .autoincrement)
                i.column(date)
                i.column(business)
                i.column(total)
            })
        }catch {
            print(error)
        }
        print("deposits table created")
    }
    
    
    func insertIncome(startDate: Date, business: String, total: Double) {
        guard let db = db else {return}
        let insert = monthlyIncomeTable.insert(
            self.startDate <- startDate,
            self.updatedDate <- startDate,
            self.business <- business,
            self.total <- total)
        do {
            let insertRow = try db.run(insert)
            print("income inserted successfully to row \(insertRow).")
        } catch {
            print("Error inserting income: \(error)")
        }
    }
    
    func insertBalance(startDate: Date, accountBalance: Double){
        guard let db = db else {return}
        
        let newBalance = balanceTable.insert(
            self.id <- 1,
            self.startDate <- startDate,
            self.updatedDate <- startDate,
            self.accountBalance <- accountBalance)
        do {
            // let count = try db.scalar("SELECT COUNT(*) FROM balance") as! Int64
            let insertRow = try db.run(newBalance)
            print("Balance edited successfully to row \(insertRow).")
        } catch {
            print("Error editing balance: \(error)")
        }
    }
    
    func insertDeposit(depositDate: Date, business: String, total: Double) {
        guard let db = db else {return}
        
        let insert = depositsTable.insert(
            self.date <- depositDate,
            self.business <- business,
            self.total <- total)
        do {
            let insertRow = try db.run(insert)
            print("Deposit inserted successfully to row \(insertRow).")
        } catch {
            print("Error inserting deposit: \(error)")
        }
    }
    
    func insertExpense(startDate: Date, business: String, category: String, total: Double) {
        guard let db = db else {return}
        let insert = monthlyExpensesTable.insert(
            self.startDate <- startDate,
            self.updatedDate <- startDate,
            self.business <- business,
            self.category <- category,
            self.total <- total)
        do {
            let insertRow = try db.run(insert)
            print("Expense inserted successfully to row \(insertRow).")
        } catch {
            print("Error inserting expense: \(error)")
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
                print("starting account balance= \(currentAccountBalance)")
                let balanceStartDate = balance[updatedDate]
                let currentDate = Date.now
                let purchasesTotal = try db.scalar(purchases.filter(date >= balanceStartDate && date <= currentDate).select(total.sum)) ?? 0.0
                let depositsTotal = try db.scalar(depositsTable.filter(date >= balanceStartDate && date <= currentDate).select(total.sum)) ?? 0.0
                let newBalance = currentAccountBalance - purchasesTotal + depositsTotal
                
                try db.run(balanceTable.update(self.accountBalance <- newBalance, self.updatedDate <- currentDate))
                print("Balance updated successfully. New balance: \(newBalance)")
            } else {
                print("No balance found. Initialize the balanceTable.")
            }
        } catch {
            print("Error updating balance: \(error)")
        }
    }
    
    func updateMonthlyIncome() {
        guard let db = db else {return}
        do {
            
            for monthlyIncome in try db.prepare(monthlyIncomeTable) {
                let itemID = monthlyIncome[id]
                let itemUpdatedDate = monthlyIncome[updatedDate]
                let itemBusiness = monthlyIncome[business]
                let itemTotal = monthlyIncome[total]
                var currentDate = itemUpdatedDate
                let calendar = Calendar.current
                
                while currentDate <= Date.now {
                    let depositDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
                    try db.run(depositsTable.insert(
                        self.date <- depositDate,
                        self.business <- itemBusiness,
                        self.total <- itemTotal))
                    currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
                    let localizedDate = dateFormatter.string(from: currentDate)
                    print("added deposit \(itemBusiness) for date: \(localizedDate)")
                }
                let incomeItem = monthlyIncomeTable.filter(id == itemID)
                try db.run(incomeItem.update(updatedDate <- currentDate))
                print("income item updated for month")
            }
            print("deposits added for all monthly incomes.")
        } catch {
            print("An error occurred: \(error)")
        }
    }
    
    func applyPurchases() {
        
    }
    
    func updateMonthlyExpenses() {
        guard let db = db else {return}
        do {
            
            for monthlyExpense in try db.prepare(monthlyExpensesTable) {
                let itemID = monthlyExpense[id]
                let itemUpdatedDate = monthlyExpense[updatedDate]
                let itemBusiness = monthlyExpense[business]
                let itemCategory = monthlyExpense[category]
                let itemTotal = monthlyExpense[total]
                var currentDate = itemUpdatedDate
                let calendar = Calendar.current
                
                while currentDate <= Date.now {
                    let purchaseDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
                    try db.run(purchases.insert(
                        self.business <- itemBusiness,
                        self.category <- itemCategory,
                        self.total <- itemTotal,
                        self.date <- purchaseDate
                    ))
                    currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
                    let localizedDate = dateFormatter.string(from: currentDate)
                    print("added expense \(itemBusiness) for date: \(localizedDate)")
                }
                let expenseItem = monthlyExpensesTable.filter(id == itemID)
                try db.run(expenseItem.update(updatedDate <- currentDate))
                print("expense item updated for month")
            }
            print("Purchases added for all monthly expenses.")
        } catch {
            print("An error occurred: \(error)")
        }
    }
    
    // Function to insert a purchase record
    func insertPurchase(business: String, category: String, total: Double, date: Date) {
        guard let db = db else {return}
        let insert = purchases.insert(
            self.business <- business,
            self.category <- category,
            self.total <- total,
            self.date <- date)
        do {
            let insertRow = try db.run(insert)
            print("Purchase inserted successfully to row \(insertRow).")
        } catch {
            print("Error inserting purchase: \(error)")
        }
    }
    
    func getPieChartData() -> [String: Double]{
        var categoryTotals = [String: Double]()
        guard let db = db else {return [:] }
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let filteredPurchases = purchases.filter(date >= startDate)

        do{
            for purchase in try db.prepare(filteredPurchases) {
                let categoryName = purchase[category]
                let purchaseTotal = purchase[total]
                if categoryTotals[categoryName] != nil {
                    categoryTotals[categoryName]! += purchaseTotal
                } else {
                    categoryTotals[categoryName] = purchaseTotal
                }
            }
            return categoryTotals
        }catch {
                print("Error fetching purchases: \(error)")
            return categoryTotals
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
            return recipts
        }
    }
    
    func getExpense() ->  [expense]{
        var allExpenses: [expense] = []
        monthlyExpensesTable = monthlyExpensesTable.order(id.desc)
        guard let db = db else { return [] }
        do {
            for row in try db.prepare( monthlyExpensesTable){
                
                let ExpenseItem = expense(
                    id: try row.get(id),
                    startDate: try row.get(startDate),
                    updatedDate: try row.get(updatedDate),
                    business: try row.get(business),
                    category: try row.get(category),
                    total: try row.get(total)
                )
                allExpenses.append(ExpenseItem)
            }
            print(allExpenses)
            return allExpenses
            
        } catch {
            print("Error fetching all monthly expences: \(error)")
            return allExpenses
        }
    }
    
    func getDeposit() -> [deposit]{
        var allDeposits: [deposit] = []
        depositsTable = depositsTable.order(id.desc)
        guard let db = db else { return [] }
        do {
            for row in try db.prepare(depositsTable){
                let depositItem = deposit(
                    id: try row.get(id),
                    date: try row.get(date),
                    business: try row.get(business),
                    total: try row.get(total)
                )
                allDeposits.append(depositItem)
            }
            print(allDeposits)
            return allDeposits
        } catch {
            print("Error fetching all deposits: \(error)")
            return allDeposits
        }
    }
    
    func getIncome() -> [income] {
        var allIncome: [income] = []
        monthlyIncomeTable = monthlyIncomeTable.order(id.desc)
        guard let db = db else { return [] }
        do {
            for row in try db.prepare(monthlyIncomeTable){
                
                let income = income(
                    id: try row.get(id),
                    startDate: try row.get(startDate),
                    updatedDate: try row.get(updatedDate),
                    business: try row.get(business),
                    total: try row.get(total)
                )
                allIncome.append(income)
            }
            print(allIncome)
            return allIncome
            
        } catch {
            print("Error fetching all income: \(error)")
            return allIncome
        }
    }
    
    func getBalance() -> balance? {
        
        guard let db = db else {return nil}
        do {
            if let balanceItem = try db.pluck(balanceTable) {
                let balanceData = balance(
                    id: balanceItem[id],
                    startDate: balanceItem[startDate],
                    updateDate: balanceItem[updatedDate],
                    accountBalance: balanceItem[accountBalance]
                )
                return balanceData
            } else {
                print("Unable to find the balace.")
                return nil
            }
        } catch {
            print("Error fetching balance: \(error)")
            return nil
        }
    }
    
    func removeIncome(incomeID: Int64){
        guard let db = db else {return}
        do {
            let incomeToRemove = monthlyIncomeTable.filter(id == incomeID)
            if try db.run(incomeToRemove.delete()) > 0 {
                print("Income with ID \(incomeID) removed successfully.")
            } else {
                print("Income with ID \(incomeID) not found.")
            }
        } catch {
            print("Error removing purchase: \(error)")
        }
    }
    
    func removeExpense(expenseID: Int64) {
        guard let db = db else {return}
        do {
            let expense = monthlyExpensesTable.filter(id == expenseID)
            
            if try db.run(expense.delete()) > 0 {
                print("Monthly expense with ID \(expenseID) removed successfully.")
            } else {
                print("Monthly expense with ID \(expenseID) not found.")
            }
        } catch {
            print("Error removing monthly expense: \(error)")
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
    
    func removeDeposit(depositID: Int64){
        guard let db = db else {return}
        do {
            let depositToDelete = purchases.filter(id == depositID)
            if try db.run(depositToDelete.delete()) > 0 {
                print("Deposit with ID \(depositID) removed successfully.")
            } else {
                print("Deposit with ID \(depositID) not found.")
            }
        } catch {
            print("Error removing deposit: \(error)")
        }
    }
    
    
    
    func getSpendingByCategory() -> [(category: String, total: Double)] {
        guard let db = db else { return [] }

        do {
            let query = purchases.select(category, total.sum).group(category)
            return try db.prepare(query).map { (category: $0[category], total: $0[total.sum] ?? 0) }
        } catch {
            print("Failed to fetch spending by category: \(error)")
            return []
        }
    }
    

    
    
    
    
}


