//
//  ExpenseView.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva on 5/10/24.
//
import SwiftUI

struct Expense: Identifiable {
    let id: Int64
    var business: String
    var category: String
    var total: Double
    var startDate: Date
}

import SwiftUI

struct ExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var expenses = [Expense]()
    @State private var showingAddExpense = false

    // Fetch expenses from the database
    private func fetchExpenses() {
        expenses = DBConnect.sharedInstance.getExpense().map {
            Expense(id: $0.id, business: $0.business, category: $0.category, total: $0.total, startDate: $0.startDate)
        }
    }

    // Compute total expenses
    private var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Total Expenses: $\(totalExpenses, specifier: "%.2f")")
                    .font(.title)
                    .padding()
                
                List(expenses) { expense in
                    VStack(alignment: .leading) {
                        Text("Business: \(expense.business)")
                        Text("Category: \(expense.category)")
                        Text("Total: $\(expense.total, specifier: "%.2f")")
                        Text("Date: \(expense.startDate, formatter: itemFormatter)")
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Monthly Expenses")
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button(action: {
                self.showingAddExpense.toggle()
            }) {
                Image(systemName: "plus")
            })
            .onAppear(perform: fetchExpenses)
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(expenses: $expenses)
            }
        }
    }
}

struct AddExpenseView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var expenses: [Expense]
    @State private var business = ""
    @State private var category = ""
    @State private var total = ""
    @State private var startDate = Date()

    var body: some View {
        NavigationView {
            Form {
                TextField("Business", text: $business)
                TextField("Category", text: $category)
                TextField("Total", text: $total)
                    .keyboardType(.decimalPad)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

                Button("Save") {
                    if let totalDouble = Double(total) {
                        DBConnect.sharedInstance.insertExpense(startDate: startDate, business: business, category: category, total: totalDouble)
                        expenses.append(Expense(id: Int64(expenses.count + 1), business: business, category: category, total: totalDouble, startDate: startDate))
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationBarItems(trailing: Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationTitle("Add Expense")
        }
    }
}

struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView()
    }
}

// Helper to format the date
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

