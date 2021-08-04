//
//  ScanPicker.swift
//  ScanPicker
//
//  Created by Andrei Chenchik on 4/8/21.
//

import SwiftUI
import VisionKit

enum ScanError: Error {
    case scanCancelled
}

struct ScanPicker: UIViewControllerRepresentable {
    @Binding var newReceipt: Receipt?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentPicker = VNDocumentCameraViewController()
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        // nothing to update here
    }

    func closePicker() {
        presentationMode.wrappedValue.dismiss()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScanPicker

        init(_ parent: ScanPicker) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.newReceipt = Receipt(from: .success(scan))
            parent.closePicker()
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.newReceipt = Receipt(from: .failure(ScanError.scanCancelled))
            parent.closePicker()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.newReceipt = Receipt(from: .failure(error))
            parent.closePicker()
        }
    }
}

//struct VisionPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ScanPicker()
//    }
//}
