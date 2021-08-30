//
//  VendorEditView.swift
//  VendorEditView
//
//  Created by Andrei Chenchik on 30/8/21.
//

import SwiftUI

struct VendorEditView: View {
    var vendor: Vendor? = nil
    var linkedReceipt: Receipt? = nil
    var vendorTitle: String? = nil

    @EnvironmentObject var dataController: DataController

    var body: some View {
        InnerView(vendor: vendor, linkedReceipt: linkedReceipt, vendorTitle: vendorTitle, dataController: dataController)
    }
}


extension VendorEditView {
    struct InnerView: View {
        var dataController: DataController
        @ObservedObject var vendor: Vendor

        @Environment(\.presentationMode) var presentationMode

        @State private var vendorTitle = ""
        @State private var isNewVendor = false

        init(vendor: Vendor?, linkedReceipt: Receipt?, vendorTitle: String?, dataController: DataController) {
            self.dataController = dataController

            if let vendor = vendor {
                _vendor = ObservedObject(wrappedValue: vendor)
            } else {
                let newVendor = Vendor(context: dataController.viewContext)
                newVendor.uuid = UUID()
                newVendor.title = vendorTitle
                linkedReceipt?.vendor = vendor
                linkedReceipt?.objectWillChange.send()
                dataController.saveIfNeeded()

                _vendor = ObservedObject(wrappedValue: newVendor)
                _isNewVendor = State(wrappedValue: true)
            }

            _vendorTitle = State(wrappedValue: self.vendor.title ?? "")
        }

        var saveButton: some ToolbarContent {
            ToolbarItem(placement: .primaryAction) {
                if !(vendor.title?.isEmpty ?? true) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                    }
                }
            }
        }

        var body: some View {
            Form {
                Section(header: Text("Title"),
                        footer: Text("If you will add EMOJI in the beginning of the title - it will became an icon of that vendor. How cool is that?!")) {
                    TextField("Vendor Title", text: $vendorTitle.onChange(updateTitle),
                              prompt: Text("🚀 Super-store"))
                }
            }
            .onDisappear(perform: {
                if vendor.title?.isEmpty ?? true {
                    dataController.delete(vendor)
                    dataController.saveIfNeeded()
                }
            })
            .toolbar {
                saveButton
            }
            .navigationTitle(isNewVendor ? "Create vendor" : "Edit vendor")
        }

        func updateTitle() {
            for receipt in vendor.vendorReceipts {
                receipt.objectWillChange.send()
            }
            vendor.title = vendorTitle
            dataController.saveIfNeeded()
        }
    }
}

struct VendorEditView_Previews: PreviewProvider {
    static var previews: some View {
        VendorEditView(vendor: Vendor.example)
    }
}
