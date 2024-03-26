import SwiftUI
import Vision
import VisionKit

struct OCRView: View {
    @Environment(\.presentationMode) var presentationMode // Access the presentation mode
    @State private var recognizedText = "Tap to scan"
    @State private var showingScanningView = false

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text(recognizedText)
                    .padding()

                Button("Scan Document") {
                    showingScanningView = true
                }
                .sheet(isPresented: $showingScanningView) {
                    ScanningView(recognizedText: $recognizedText)
                }
            }
            .padding([.top, .leading, .bottom])
            .navigationBarTitle("OCR Scanner")
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss() // Dismiss the view
            })
        }
    }
}

struct ScanningView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedText: String

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var recognizedText: Binding<String>
        var parent: ScanningView

        init(recognizedText: Binding<String>, parent: ScanningView) {
            self.recognizedText = recognizedText
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

                DispatchQueue.main.async {
                    self?.recognizedText.wrappedValue = recognizedStrings.joined(separator: "\n")
                }
            }

            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error.localizedDescription)")
            }
        }
    }
}

struct OCRView_Previews: PreviewProvider {
    static var previews: some View {
        OCRView()
    }
}
