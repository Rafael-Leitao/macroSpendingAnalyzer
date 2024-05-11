//
//  Income.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva on 5/10/24.
//

import Foundation

struct income : Identifiable {
    var id: Int64
    var startDate: Date
    var updatedDate: Date
    var endDate: Date
    var business: String
    var total: Double
}

