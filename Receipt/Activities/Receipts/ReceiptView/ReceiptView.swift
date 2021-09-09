//
//  ReceiptView.swift
//  ReceiptView
//
//  Created by Andrei Chenchik on 23/8/21.
//

import CoreData
import SwiftUI

struct ReceiptView: View {
    var receipt: Receipt
    @EnvironmentObject var dataController: DataController

    var body: some View {
        InnerView(receipt: receipt, dataController: dataController)
    }
}

extension ReceiptView {
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
                RelationPicker<Store>("Store", selection: $viewModel.selectedStoreURL, navigationTitle: "Select store")

                Section(header: Text("Purchase Date & location")) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .frame(width: 30)

                        DatePicker("Date", selection: $viewModel.receiptPurchaseDate, in: ...Date())
                            .lineLimit(1)
                    }


                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .frame(width: 30)

                        TextField("Venue Address", text: $viewModel.receiptPurchaseAddress)
                    }

                    if let region = viewModel.addressLocation {
                        MapView(region: region)
                    }
                }

                Section(header: Text("Shopping cart")) {
                    ForEach(Array(viewModel.receipt.receiptItemsSorted.enumerated()), id: \.element) { index, item in
                        ItemView(item: item)
                            .listRowBackground(
                                Color(.secondarySystemGroupedBackground)
                                    .opacity(index % 2 == 0 ? 1 : 0.5)
                            )
                            .listRowSeparator(index != 0 ? .hidden : .automatic, edges: .top)
                    }
                    .onDelete(perform: viewModel.deleteItems)


                }

                Section {
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

struct ReceiptView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        ReceiptView(receipt: Receipt.example)
            .environmentObject(dataController)
    }
}
