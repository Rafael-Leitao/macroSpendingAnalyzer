//
//  receipt.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva & Rafael Leitao on 4/9/24.
//

import Foundation

struct receipt : Identifiable {
    var id: Int64
    var date: Date
    var business: String
    var category: String
    var total: Double
}

