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

    // Fetch spending data by category from DBConnect
    private func fetchData() {
        // Assuming DBConnect has a function to get spending by category
        let results = DBConnect.sharedInstance.getSpendingByCategory()
        chartData = results.map { ChartData(category: $0.category, total: $0.total) }
    }

    var body: some View {
        NavigationView {
            VStack {
                if !chartData.isEmpty {
                    Chart(chartData, id: \.category) { data in
                        SectorMark(
                            angle: .value("Spending", data.total)
                            //stacking: .normalized
                        )
                        .foregroundStyle(by: .value("Category", data.category))
                    }
                    .padding()
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

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
