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
    
    // Create new database or establish connection
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
        let id  = Expression<Int64>("id")
        let date = Expression<Date>("date")
        let business = Expression<String>("business")
        let catagory =  Expression <String>("category")
        let product = Expression <String>("product")
        let total = Expression <Double>("total")
        
        let purchases = Table("purchases")
        
        do {
            try db.run(purchases.create {p in
                p.column(id, primaryKey: .autoincrement)
                p.column(business)
                p.column(catagory)
                p.column(product)
                p.column(total)
                p.column(date)
            })
        }catch {
            print(error)
        }
    }
}
