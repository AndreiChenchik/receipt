//
//  VendorEditView.swift
//  VendorEditView
//
//  Created by Andrei Chenchik on 30/8/21.
//

import SwiftUI

struct VendorEditView: View {
    let dataController = DataController.shared

    @Environment(\.dismiss) var dismiss

    @State private var vendorTitle = ""

    var vendor: Vendor? = nil
    var receipt: Receipt? = nil

    init() {}

    init(vendor: Vendor) {
        self.vendor = vendor
        _vendorTitle = State(wrappedValue: vendor.vendorTitle)
    }

    init(receipt: Receipt, vendorTitle: String) {
        self.receipt = receipt
        _vendorTitle = State(wrappedValue: vendorTitle)
    }

    func saveChanges() {
        let vendorTitle = vendorTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        if let vendor = vendor {
            dataController.updateVendor(vendor.objectID, title: vendorTitle)
        } else {
            dataController.createVendor(with: vendorTitle, linkedTo: receipt?.objectID)
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Title"),
                    footer: Text("If you will add EMOJI in the beginning of the title - it will became an icon of that vendor. How cool is that?!")) {
                TextField("Vendor Title", text: $vendorTitle,
                          prompt: Text("🚀 Super-store"))
            }

            Button(vendor == nil ? "Create vendor" : "Update vendor") {
                saveChanges()
                dismiss()
            }
            .disabled(vendorTitle.isEmpty)
        }
        .navigationTitle(vendor == nil ? "New vendor" : "Edit vendor")
    }
}


struct VendorEditView_Previews: PreviewProvider {
    static var previews: some View {
        VendorEditView(vendor: Vendor.example)
    }
}
