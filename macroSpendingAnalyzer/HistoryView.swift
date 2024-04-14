//
//  HistoryView.swift
//  macroSpendingAnalyzer
//
//  Created by Rafael Leitao on 3/26/24.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode // Access the presentation mode

    // for testing
    
  // @State var purchase = DBConnect.sharedinstence.getPurchase()
    @State var scannedTexts: [Receipt] = []

//    struct Receipt : Identifiable {
//        var date: Date
//        var business: String
//        var category: String
//        var product: String
//        var total: Double
//        let id = UUID()
//    }

    var body: some View {

//        Table(scannedTexts) {
//            TableColumn("Business", value: \.business)
//            TableColumn("Category", value: \.category)
//            TableColumn("Product", value: \.product)
//          //  TableColumn("Total", value: \.total)
//          //  TableColumn("Date" , value: \.date)
//                
//               }
//               .navigationTitle("Purchases")
//               .onAppear(perform: {
//                   self.scannedTexts = DBConnect.sharedinstence.getPurchase()
//               })
        List(self.scannedTexts) { (Receipt) in
            HStack {
                Text("\(Receipt.date, formatter: dateFormatter)")
                Spacer()
                Text(Receipt.business)
                Spacer()
                Text(Receipt.category)
            }
            
        }
                       .navigationTitle("Purchases")
                       .onAppear(perform: {
                           self.scannedTexts = DBConnect.sharedinstence.getPurchase()
                       })
           }
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

