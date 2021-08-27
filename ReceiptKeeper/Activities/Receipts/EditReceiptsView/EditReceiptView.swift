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

        var body: some View {
            Form {
                Picker("Select vendor", selection: $viewModel.receiptVendorIndex) {
                    ForEach(viewModel.vendors) { vendor in
                        Text(vendor.title ?? "Unknown").tag(vendor.uuid?.hashValue ?? -1)
                    }
                    Label("Add new vendor", systemImage: "plus").tag(-2)
                }

                Section(header: Text("Date & location")) {
                    TextField("Venue Address", text: $viewModel.receiptPurchaseAddress)
                    DatePicker("Purchase date", selection: $viewModel.receiptPurchaseDate, in: ...Date())
                }

                Section(header: Text("Shopping cart")) {
                    ForEach(viewModel.receipt.receiptItems, id: \.self) { item in
                        VStack(alignment: .leading) {
                            Text(item.title ?? "Unknown")
                            Text("\(item.price ?? 0)")
                        }
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
                    TextField("Total amount", text: $viewModel.receiptTotal)
                        .keyboardType(.decimalPad)
                }

                Section {
                    NavigationLink("Recognized Receipt", destination: RecognizedContentView(receipt: viewModel.receipt))
                }
            }
            .alert(isPresented: $viewModel.isShowingNewVendorAlert, TextFieldAlert(title: "Create new vendor", message: "Set a name for new vendor", defaultText: viewModel.venueTitle ?? "", action: { (text) in
                        if let text = text {
                            self.viewModel.addVendor(title: text)
                        } else {
                            print("canceled")
                        }
            }))
            .navigationTitle("Receipt")
        }
    }
}

//struct EditReceiptView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditReceiptView()
//    }
//}


//struct SelectedDraftLineView: View {
//    @ObservedObject var receiptLine: DraftLine
//    @ObservedObject var receiptDraft: Draft
//
//    @Binding var lineSelectedForPopup: DraftLine?
//
//    var body: some View {
//        HStack {
//            VStack{
//                TextField("Label", text: $receiptLine.label)
//
//                TextField("Value", text: $receiptLine.value)
//                    .multilineTextAlignment(.trailing)
//            }
//        }
//        .frame(height: receiptLine.selected ? 55 : 35)
//        .swipeActions {
//            Button(role: .destructive) {
//                withAnimation {
//                    receiptDraft.objectWillChange.send()
//                    receiptLine.selected = false
//                }
//            } label: {
//                Image(systemName: "cart.badge.minus")
//            }
//        }
//        .swipeActions(edge: .leading, allowsFullSwipe: false) {
//            Button {
//                withAnimation {
//                    lineSelectedForPopup = receiptLine
//                }
//            } label: {
//                Image(systemName: "square.dashed.inset.filled")
//            }
//            .tint(.blue)
//        }
//    }
//}
//
////struct ReceiptLineView_Previews: PreviewProvider {
////    static var previews: some View {
////        SelectedDraftLineView()
////    }
////}
