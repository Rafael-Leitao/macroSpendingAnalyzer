//
//  IncomeView.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva on 5/10/24.
//
import SwiftUI

struct IncomeView: View {
    @State private var incomes = [income]()
    @State private var showingAddIncome = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(incomes) { income in
                    VStack(alignment: .leading) {
                        Text("Business: \(income.business)")
                        Text("Total: \(income.total)")
                    }
                }
            }
            .navigationTitle("Incomes")
            .navigationBarItems(trailing: Button(action: {
                self.showingAddIncome.toggle()
            }) {
                Image(systemName: "plus")
            })
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView(incomes: self.$incomes)
        }
        .onAppear {
            self.incomes = DBConnect.sharedInstance.getIncome()
        }
    }

}

struct AddIncomeView: View {
    @Binding var incomes: [income]
    @State private var business = ""
    @State private var total = ""
    @State private var startDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Income Details")) {
                    TextField("Business", text: $business)
                    TextField("Total", text: $total)
                        .keyboardType(.numberPad)
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }
                
                Button("Save") {
                    if let total = Double(total) {
                        DBConnect.sharedInstance.insertIncome(startDate: startDate, updatedDate: startDate, business: business, total: total)
                    }

                }
            }
            .navigationTitle("Add Income")
            .navigationBarItems(trailing: Button("Dismiss") {
                // Dismiss the sheet
            })
        }
    }
}

struct IncomeView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeView()
    }
}
