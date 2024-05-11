import SwiftUI
import Vision
import VisionKit

struct ReceiptDetails {
    var businessName: String = ""
    var date: Date = Date()
    var total: String = ""
    var category: String = ""
    var isDateSet: Bool = false
}

// This view is responsible for initializing the scanning process.
struct OCRView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var recognizedText = ""
    @State private var showingScanningView = false
    @State private var receiptDetails = ReceiptDetails()
    @State private var showingDatePicker = false
    @State private var formattedDate = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none) // Initialize with current date
    @State private var showAlert = false
    @State private var alertMessage = ""



    var body: some View {
            NavigationView {
                VStack(alignment: .center) {
                    ScrollView {
                        
                        Text("Business:")
                            .font(.headline)
                            .padding(.top)
                        
                        TextField("Enter business name", text: $receiptDetails.businessName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Text("Category:")
                            .font(.headline)
                            .padding(.top)
                        
                        TextField("Enter category", text: $receiptDetails.category)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Text("Date:")
                            .font(.headline)
                            .padding(.top)
                        
                        
                        TextField("Date", text: $formattedDate, onEditingChanged: { isEditing in
                            if isEditing { showingDatePicker = true }
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .onTapGesture {
                            showingDatePicker = true
                        }

                        if showingDatePicker {
                            DatePicker(">", selection: $receiptDetails.date, displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .onChange(of: receiptDetails.date) { newDate in
                                    formattedDate = DateFormatter.localizedString(from: newDate, dateStyle: .medium, timeStyle: .none)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }

                        
                        Text("Total:")
                            .font(.headline)
                            .padding(.top)
                        
                        TextField("Enter total", text: $receiptDetails.total)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .padding()

                        Button("Scan Document") {
                            showingScanningView = true
                        }
                        .sheet(isPresented: $showingScanningView) {
                            ScanningView(recognizedText: $recognizedText, receiptDetails: $receiptDetails)
                        }
                        
                        Button("Add") {
                            if validateInputs() {
                                addPurchaseToDatabase()
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                showAlert = true
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Ops"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        .padding([.top, .bottom])
                        .frame(width: 300)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)

                    }
                    .navigationBarTitle("Type in or Scan a receipt")
                    .navigationBarItems(leading: Button("Back") {
                        presentationMode.wrappedValue.dismiss()  // Dismiss the view
                    })
                }
                .padding([.top, .leading, .bottom])
            }
        }
        private func addPurchaseToDatabase() {
            guard let total = Double(receiptDetails.total) else {
                print("Error: Total amount is not a valid number")
                return
            }

            // Use the shared instance to insert the purchase
            DBConnect.sharedInstance.insertPurchase(business: receiptDetails.businessName,
                                                    category: receiptDetails.category,
                                                    total: total,
                                                    date: receiptDetails.date)
            print("Purchase details added to database")
            DBConnect.sharedInstance.printAllPurchases()
            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }

        }
    
        private func validateInputs() -> Bool {
            if receiptDetails.businessName.isEmpty {
                alertMessage = "Please enter a business name."
                return false
            } else if receiptDetails.category.isEmpty {
                alertMessage = "Please enter a category."
                return false
            } else if receiptDetails.total.isEmpty {
                alertMessage = "Please enter a total amount."
                return false
            }
            return true
        }


    
    
}

// We use this to view controller to capture images of receipts.
struct ScanningView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedText: String
    @Binding var receiptDetails: ReceiptDetails
    

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, receiptDetails: $receiptDetails, parent: self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var recognizedText: Binding<String>
        var receiptDetails: Binding<ReceiptDetails>
        var parent: ScanningView

        init(recognizedText: Binding<String>, receiptDetails: Binding<ReceiptDetails>, parent: ScanningView) {
                self.recognizedText = recognizedText
                self.receiptDetails = receiptDetails
                self.parent = parent
            }

            func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
                let image = scan.imageOfPage(at: 0)
                recognizeTextInImage(image)
                parent.presentationMode.wrappedValue.dismiss()
            }

            private func recognizeTextInImage(_ image: UIImage) {
                guard let cgImage = image.cgImage else { return }
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                let request = VNRecognizeTextRequest { [weak self] request, error in
                    guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else { return }
                    let recognizedStrings = observations.compactMap { observation in
                        observation.topCandidates(1).first?.string
                    }
                    let fullText = recognizedStrings.joined(separator: "\n")
                    DispatchQueue.main.async {
                        self?.recognizedText.wrappedValue = fullText
                        self?.parseText(fullText)
                    }
                }

                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform text recognition: \(error.localizedDescription)")
                }
            }

            private func parseText(_ text: String) {
                let lines = text.split(separator: "\n").map(String.init)
                
                // Assuming the first line is always the business name.
                receiptDetails.businessName.wrappedValue = lines.first ?? "Unknown"

                var foundAmount = false  // Flag to control when to look for the amount

                for line in lines {
                    
                    if line.lowercased().contains("store") {
                        receiptDetails.category.wrappedValue = "Food"
                    }
                    
                    // Use the wrappedValue to access and modify the date
                    if !receiptDetails.isDateSet.wrappedValue, let date = extractDate(line) {
                        receiptDetails.date.wrappedValue = date
                        receiptDetails.isDateSet.wrappedValue = true  // Mark the date as manually set
                    }


                    // Check for keywords related to total and attempt to extract the amount
                    if !foundAmount && (line.lowercased().contains("total purchase") || line.lowercased().contains("payment amount")) {
                        foundAmount = true  // Indicate that amount might be on this or next lines
                        
                    }
                    
                    if foundAmount && receiptDetails.total.wrappedValue.isEmpty, let amount = extractAmount(line) {
                        receiptDetails.total.wrappedValue = amount
                        
                        foundAmount = false // Reset the flag in case more totals are listed but keep scanning for dates
                    }
                }
            }


            private func extractAmount(_ line: String) -> String? {
                let pattern = "(\\d+[.,]\\d+)"  // Regex to match monetary values with decimals
                do {
                    let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                    let range = NSRange(location: 0, length: line.utf16.count)
                    if let match = regex.firstMatch(in: line, options: [], range: range) {
                        if let amountRange = Range(match.range(at: 1), in: line) {
                            let foundAmount = String(line[amountRange])
                            
                            return foundAmount
                        }
                    }
                } catch {
                    print("Regex error: \(error)")  // Debugging: Regex error
                }
                return nil
            }

            private func extractDate(_ line: String) -> Date? {
                let pattern = "\\b(\\d{1,2}[-/\\.]\\d{1,2}[-/\\.]\\d{2,4})\\b"  // Regex to match common date formats
                do {
                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                    let range = NSRange(location: 0, length: line.utf16.count)
                    if let match = regex.firstMatch(in: line, options: [], range: range) {
                        if let dateRange = Range(match.range, in: line) {
                            let foundDate = String(line[dateRange])
                            
                            // Convert the found date string to Date
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM-dd-yy"  // Adjust the date format as per your actual needs
                            return dateFormatter.date(from: foundDate)
                        }
                    }
                    
                } catch {
                    print("Regex error: \(error)")  // Debugging: Regex error
                }
                return nil
            }
    }
}

struct OCRView_Previews: PreviewProvider {
    static var previews: some View {
        OCRView()
    }
}
