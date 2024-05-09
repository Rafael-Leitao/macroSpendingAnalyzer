//
//  ContentView.swift
//  macroSpendingAnalyzer
//
//  Created by Rafael Leitao on 3/26/24.
//

import SwiftUI


struct ContentView: View {
    @State private var titleOpacity: Double = 1.0
    @State private var buttonsOpacity: Double = 0.0
    @State private var showOCRView = false
    @State private var showHistoryView = false

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
                Text("Add a new receipt")
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
                showHistoryView = true
            }) {
                Text("History")
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
        .background(Color("green")) // Set the background color to dark green
        .edgesIgnoringSafeArea(.all) // Extend the background to fill the entire screen
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


