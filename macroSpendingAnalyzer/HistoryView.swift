//
//  HistoryView.swift
//  macroSpendingAnalyzer
//
//  Created by Rafael Leitao on 3/26/24.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode // Access the presentation mode

    let scannedTexts: [String] = ["Scan 1", "Scan 2", "Scan 3"]

    var body: some View {
        NavigationView {
            List(scannedTexts, id: \.self) { text in
                Text(text)
            }
            .navigationBarTitle("History")
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss() // Dismiss the view
            })
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

