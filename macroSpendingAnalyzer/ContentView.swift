//
//  ContentView.swift
//  macroSpendingAnalyzer
//
//  Created by Anthony Silva & Rafael Leitao on 3/26/24.
//

import SwiftUI


struct ContentView: View {
    @State private var titleOpacity: Double = 1.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var showOCRView = false
    @State private var showHistoryView = false
    @State private var showIncomeView = false
    @State private var showStatisticsView = false
    @State private var showExpenseView = false

    private var db = DBConnect()
    

    var body: some View {
        VStack(spacing: 20) {
            Text("Macro Spending Analyzer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .opacity(titleOpacity)
            
            Button(action: {
                showOCRView = true
            }) {
                Text("New Receipt")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .opacity(buttonsOpacity)
            .sheet(isPresented: $showOCRView) {
                OCRView()
            }
            
            Button(action: {
                showStatisticsView  = true
            }) {
                Text("Your Stats    ")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .opacity(buttonsOpacity)
            .sheet(isPresented: $showStatisticsView) {
                StatisticsView()
            }
            
            Button(action: {
                showExpenseView  = true
            }) {
                Text("Your Expenses    ")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .opacity(buttonsOpacity)
            .sheet(isPresented: $showExpenseView) {
                ExpenseView()
            }
            
            
            
            Button(action: {
                showIncomeView = true
            }) {
                Text(" Edit Income ")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .opacity(buttonsOpacity)
            .sheet(isPresented: $showIncomeView) {
                IncomeView()
            }

            Button(action: {
                showHistoryView = true
            }) {
                Text(" Your History ")
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .opacity(buttonsOpacity)
            .sheet(isPresented: $showHistoryView) {
                HistoryView()
            }
        }
        .padding()
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2).delay(1)) {
                titleOpacity = 0.0
                buttonsOpacity = 1.0
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


