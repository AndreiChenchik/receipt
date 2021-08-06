//
//  ScanPickerView.swift
//  ScanPickerView
//
//  Created by Andrei Chenchik on 4/8/21.
//

import SwiftUI
import VisionKit

struct ScanPickerView: UIViewControllerRepresentable {
    @Binding var isFinishedPicking: Bool

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var recognizer: Recognizer

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let receiptsPicker = VNDocumentCameraViewController()
        receiptsPicker.delegate = context.coordinator

        return receiptsPicker
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // nothing to update here
    }

    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScanPickerView

        init(_ parent: ScanPickerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            var receiptScans = [UIImage]()
            
            for index in 0..<scan.pageCount {
                let image = scan.imageOfPage(at: index)
                receiptScans.append(image)
            }

            parent.recognizer.setScans(receiptScans)
            parent.isFinishedPicking = true
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.dismiss()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            #warning("add error handling")
            parent.dismiss()
        }
    }
}

//struct VisionPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ScanPickerView()
//    }
//}
