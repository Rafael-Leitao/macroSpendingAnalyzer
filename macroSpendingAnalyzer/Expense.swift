//
//  Expense.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva on 5/12/24.
//

import Foundation
struct expense : Identifiable {
    var id: Int64
    var startDate: Date
    var updatedDate: Date
    var business: String
    var category: String
    var total: Double
}
