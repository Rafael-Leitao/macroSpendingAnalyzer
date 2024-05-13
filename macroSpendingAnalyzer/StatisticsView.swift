//
//  ContentView.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva & Rafael Leitao on 5/10/24.
//

import SwiftUI
import Charts

// Data model for the chart
struct ChartData {
    var category: String
    var total: Double
}

struct StatisticsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var chartData = [ChartData]()
    @State private var totalSpent: Double = 0
    @State private var totalBalance: Double = 0

    // Fetch spending data by category from DBConnect
    private func fetchData() {
        // Using getPieChartData to fetch data
        let categoryTotals = DBConnect.sharedInstance.getPieChartData()
        chartData = categoryTotals.map { ChartData(category: $0.key, total: $0.value) }
        totalSpent = categoryTotals.values.reduce(0, +)
        totalBalance = DBConnect.sharedInstance.getBalance()?.accountBalance ?? 0
    }

    var body: some View {
            NavigationView {
                ScrollView { // Wrap content in a ScrollView
                    VStack {
                        Text("Total Balance: $\(totalBalance, specifier: "%.2f")")
                            .font(.title)
                            .padding()

                        if !chartData.isEmpty {
                            // Pie Chart
                            Chart(chartData, id: \.category) { data in
                                SectorMark(
                                    angle: .value("Spending", data.total),
                                    innerRadius: .ratio(0.618)
                                )
                                .foregroundStyle(by: .value("Category", data.category))
                            }
                            .frame(height: 300) // Set an explicit height for the chart
                            .overlay(
                                Text("Total Spent:\n $\(totalSpent, specifier: "%.2f")")
                                    .font(.title)
                                    .foregroundColor(.primary)
                            )

                            // Bar Chart
                            Chart(chartData, id: \.category) { data in
                                BarMark(
                                    x: .value("Category", data.category),
                                    y: .value("Spending", data.total)
                                )
                                .foregroundStyle(by: .value("Category", data.category))
                                .annotation(position: .top) {
                                    Text("\(data.total, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(height: 300) // Set an explicit height for the chart

                            Spacer() // Use spacers to distribute space evenly
                        } else {
                            Text("No data available")
                        }
                    }
                    .onAppear(perform: fetchData)
                    .navigationBarTitle("Statistics", displayMode: .inline)
                    .navigationBarItems(leading: Button("Back") {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }
    }


struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
