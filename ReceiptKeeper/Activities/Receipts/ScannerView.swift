//
//  ScannerView.swift
//  ScannerView
//
//  Created by Andrei Chenchik on 4/8/21.
//

import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    static var isCapableToScan: Bool {
        VNDocumentCameraViewController.isSupported
    }

    @EnvironmentObject var dataController: DataController

    @Environment(\.presentationMode) var presentationMode

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
        var parent: ScannerView

        init(_ parent: ScannerView) {
            self.parent = parent
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            for index in 0..<scan.pageCount {
                let scanImage = scan.imageOfPage(at: index)
                parent.dataController.addReceiptDraft(with: scanImage)
            }

            parent.dismiss()
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

//  struct VisionPicker_Previews: PreviewProvider {
//      static var previews: some View {
//          ScannerView()
//      }
//  }
