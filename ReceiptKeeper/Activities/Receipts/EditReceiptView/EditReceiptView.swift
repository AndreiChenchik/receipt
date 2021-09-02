//
//  EditReceiptView.swift
//  EditReceiptView
//
//  Created by Andrei Chenchik on 23/8/21.
//

import CoreData
import SwiftUI

struct EditReceiptView: View {
    var receipt: Receipt
    @EnvironmentObject var dataController: DataController

    var body: some View {
        InnerView(receipt: receipt, dataController: dataController)
    }
}

extension EditReceiptView {
    struct InnerView: View {
        @Environment(\.presentationMode) var presentationMode

        @ObservedObject var receipt: Receipt
        @StateObject var viewModel: ViewModel

        init(receipt: Receipt, dataController: DataController) {
            let viewModel = ViewModel(receipt: receipt, dataController: dataController)
            _viewModel = StateObject(wrappedValue: viewModel)
            _receipt = ObservedObject(wrappedValue: receipt)
        }

        var saveButton: some ToolbarContent {
            ToolbarItem(placement: .primaryAction) {
                if receipt.state == .draft {
                    Button(action: {
                        viewModel.saveReceipt()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label("Save", systemImage: "checkmark.circle")
                    }
                }
            }
        }

        var body: some View {
            Form {
                Picker("Store", selection: $viewModel.selectedVendorIndex) {
                    ForEach(0..<viewModel.vendors.count) { index in
                        Text(viewModel.vendors[index].vendorTitle).tag(index)
                    }
                }

                Section(header: Text("Purchase Date & location")) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .frame(width: 30)

                        DatePicker("Purchased", selection: $viewModel.receiptPurchaseDate, in: ...Date())
                    }


                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .frame(width: 30)

                        TextField("Venue Address", text: $viewModel.receiptPurchaseAddress)
                    }

                    if let region = viewModel.addressLocation {
                        ReceiptMapView(region: region)
                    }
                }

                Section(header: Text("Shopping cart")) {
                    ForEach(viewModel.receipt.receiptItemsSorted) { item in
                        ReceiptItemView(item: item)
                    }
                    .onDelete(perform: viewModel.deleteItems)
                    
                    Button {
                        withAnimation {
                            viewModel.addItem()
                        }
                    } label: {
                        Label("Add New Item", systemImage: "plus")
                    }
                }

                Section(header: Text("Total")) {
                    HStack {
                        Image(systemName: "sum")
                            .frame(width: 30)

                        TextField("Total amount", text: $viewModel.receiptTotal)
                            .keyboardType(.decimalPad)

                        Spacer()

                        Text("€")
                    }
                }

                if viewModel.isShowingRecognizedData {
                    Section {
                        NavigationLink(destination: RecognizedContentView(receipt: viewModel.receipt)) {
                            HStack {
                                Image(systemName: "doc.text.viewfinder")
                                    .frame(width: 30)

                                Text("Recognized Receipt")
                            }
                        }
                    }
                }
            }
            .toolbar {
                saveButton
            }
            .navigationTitle("Receipt")
        }
    }
}

struct EditReceiptView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        EditReceiptView(receipt: Receipt.example)
            .environmentObject(dataController)
    }
}
