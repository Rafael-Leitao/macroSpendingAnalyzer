//
//  receipt.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva on 4/9/24.
//

import Foundation

struct Receipt : Identifiable {
    var id: Int64
    var date: Date
    var business: String
    var category: String
    var product: String
    var total: Double
}
