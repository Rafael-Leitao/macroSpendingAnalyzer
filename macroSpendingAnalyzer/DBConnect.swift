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
    
    
}
