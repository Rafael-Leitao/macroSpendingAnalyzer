//
//  HistoryView.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva & Rafael Leitao on 3/26/24.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.presentationMode) var modepresentationMode // Access the presentation mode

    // for testing
    @State var receiptId: Int64 = 0
    @State var reciptSelected = false
    @State var transactions: [receipt] = []


    
    var body: some View {

            List(self.transactions) { (receipt) in
                HStack {
                    VStack{
                        
                        Text(receipt.business)
                       
                        Text("\(receipt.date, formatter: dateFormatter)")
                    }
                    
                    Spacer()
                    Text(receipt.total,format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                }
            }
        
            .navigationTitle("Purchases")
            .navigationBarItems(leading: Button("Back") {
                            self.modepresentationMode.wrappedValue.dismiss()
                        })
            .onAppear(perform: {
                self.transactions = DBConnect.sharedInstance.getPurchase()
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

