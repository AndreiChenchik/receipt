//
//  EditReceiptView.swift
//  EditReceiptView
//
//  Created by Andrei Chenchik on 23/8/21.
//

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
        @StateObject var viewModel: ViewModel

        @ObservedObject var receipt: Receipt

        init(receipt: Receipt, dataController: DataController) {
            let viewModel = ViewModel(receipt: receipt, dataController: dataController)
            _viewModel = StateObject(wrappedValue: viewModel)
            _receipt = ObservedObject(wrappedValue: receipt)
        }

        var body: some View {
            Form {
                Text("Condis")

                Section(header: Text("Date & location")) {
                    TextField("Venue Address", text: $viewModel.receipt.receiptVenueAddress)
                    DatePicker("Purchase date", selection: $viewModel.receipt.receiptPurchaseDate, in: ...Date())
                }

                Section(header: Text("Shopping cart")) {
                    ForEach(viewModel.receipt.receiptItems) { item in
                        VStack(alignment: .leading) {
                            Text(item.title ?? "Unknown")
                            Text("\(item.price ?? 0)")
                        }
                    }
                    .onDelete { _ = $0.map { viewModel.dataController.delete(viewModel.receipt.receiptItems[$0]) }
                    }
                    Button {
                        withAnimation {
                            viewModel.addItem()
                        }
                    } label: {
                        Label("Add New Item", systemImage: "plus")
                    }
                }

                Section(header: Text("Total")) {
                    TextField("Total amount", text: $viewModel.receipt.totalString)
                }

                Section {
                    NavigationLink("Recognized Receipt", destination: RecognizedContentView(receipt: receipt))
                }
            }
            .onDisappear(perform: viewModel.saveChanges)
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
