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
                TextField("Title", text: $viewModel.title)

                Section {
                    DatePicker("Purchase date", selection: $viewModel.purchaseDate, in: ...Date())
                }

                Section {
                    TextField("Title", text: $viewModel.total)
                }

                Section {
                    NavigationLink("Recognized Receipt", destination: RecognizedContentView(receipt: receipt))
                }
            }
            .onDisappear(perform: viewModel.saveChanges)
        }
    }
}

//struct EditReceiptView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditReceiptView()
//    }
//}
