//
//  VendorsView.swift
//  VendorsView
//
//  Created by Andrei Chenchik on 27/8/21.
//

import SwiftUI

struct VendorsView: View {
    static let tag: String? = "Receipts"

    @EnvironmentObject var dataController: DataController
    var body: some View {
        InnerView(dataController: dataController)
    }
}

extension VendorsView {
    struct InnerView: View {
        @StateObject var viewModel: ViewModel

        @State private var isShowingNewVendorScreen = false

        init(dataController: DataController) {
            let viewModel = ViewModel(dataController: dataController)
            _viewModel = StateObject(wrappedValue: viewModel)
        }

        var newVendorButton: some ToolbarContent {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: VendorEditView(), isActive: $isShowingNewVendorScreen) {
                    Button(action: {
                        isShowingNewVendorScreen = true
                    }) {
                        Label("Add store", systemImage: "plus")
                    }
                }
            }
        }


        var body: some View {
            NavigationView {
                List {
                    ForEach(viewModel.vendors) { vendor in
                        NavigationLink(destination: VendorEditView(vendor: vendor)) {
                            HStack {
                                if let vendorIcon = vendor.vendorIcon {
                                    Text("\(vendorIcon)")
                                        .font(.title2)
                                        .frame(width: 30)

                                    Text(vendor.vendorTitleWithoutIcon)
                                } else {
                                    Text(vendor.vendorTitle)
                                }

                                Spacer()

                                Text(vendor.vendorReceiptsSumString)
                                Text("€")
                            }
                        }
                    }
                    .onDelete(perform: viewModel.deleteVendor)
                }
                .toolbar {
                    newVendorButton
                }
                .navigationTitle("Vendors")
            }
        }
    }
}

struct VendorsView_Previews: PreviewProvider {
    static var dataController = DataController.preview

    static var previews: some View {
        VendorsView()
            .environmentObject(dataController)
    }
}
