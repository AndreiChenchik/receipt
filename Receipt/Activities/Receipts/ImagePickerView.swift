//
//  ImagePickerView.swift
//  ImagePickerView
//
//  Created by Andrei Chenchik on 7/9/21.
//

import SwiftUI
import Vision

struct ImagePickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var newImages: [UIImage]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // do nothing
    }
}

extension ImagePickerView {
    class Coordinator: NSObject, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
    }
}

extension ImagePickerView.Coordinator: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let uiImage = info[.originalImage] as? UIImage,
           let normalizedUIImage = uiImage.normalizeOrientation(),
           let docImage = extractDocument(from: normalizedUIImage) {
            parent.newImages.append(docImage)
        }

        parent.dismiss()
    }

    func extractDocument(from uiImage: UIImage) -> UIImage? {
        guard let cgImage = uiImage.cgImage else { return nil }

        var docBoundaries: [VNRectangleObservation]? = nil

        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let detectDocumentRequest = VNDetectDocumentSegmentationRequest { request, _ in
            docBoundaries = request.results as? [VNRectangleObservation]
        }

        do {
            try imageRequestHandler.perform([detectDocumentRequest])
        } catch let error {
            print("Error detecting document on image: \(error.localizedDescription)")
        }

        if let docBoundaries = docBoundaries,
           let normalizedDocRect = docBoundaries.first?.boundingBox {
            let docRect = normalizedDocRect.imageRectFromNormalizedRect(with: uiImage.size)

            return UIImage(cgImage: cgImage).cropped(to: docRect)
        } else {
            return nil
        }
    }
}

//struct ImagePickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePickerView()
//    }
//}
