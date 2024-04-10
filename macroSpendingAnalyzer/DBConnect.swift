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
    let product = Expression <String>("product")
    let total = Expression <Double>("total")
    
    let purchases = Table("purchases")
    // Create new database or establish connection using app documents directory
    
    init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            
            self.db = try Connection("\(path)/db.sqlite3")
            
            print("Connection established")
        } catch {
            print(error)
        }
    }
    
    func createPurchaseTable() {
        
        //optional type 'Connection?' must be unwrapped to refer to member 'run' of wrapped base type 'Connection
        // TODO check generics
        guard let db = db else {return}
        
        // use optional generics for expressions that can evaluate to null

        
        // TODO check that the table hasn't already been created
        do {
            try db.run(purchases.create {p in
                p.column(id, primaryKey: .autoincrement)
                p.column(business)
                p.column(category)
                p.column(product)
                p.column(total)
                p.column(date)
            })
        }catch {
            print(error)
        }
    }
    
    // Function to insert a purchase record
    func insertPurchase(_ business: String, category: String, product: String, total: Double, date: Date) {
        guard let db = db else {return}
        let insert = purchases.insert(
            self.business <- business,
            self.category <- category,
            self.product <- product,
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
