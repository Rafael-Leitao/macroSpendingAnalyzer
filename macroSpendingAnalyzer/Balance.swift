//
//  balance.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva & Rafael Leitao on 5/12/24.
//

import Foundation

struct balance : Identifiable {
    var id: Int64
    var startDate: Date
    var updateDate: Date
    var accountBalance: Double
}
