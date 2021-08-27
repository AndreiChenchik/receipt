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

        init(dataController: DataController) {
            let viewModel = ViewModel(dataController: dataController)
            _viewModel = StateObject(wrappedValue: viewModel)
        }

        var body: some View {
            List {
                ForEach(viewModel.vendors) { vendor in
                    Text(vendor.title ?? "Unknown")
                }
                .onDelete(perform: viewModel.deleteVendor)
            }
        }
    }
}

struct VendorsView_Previews: PreviewProvider {
    static var previews: some View {
        VendorsView()
    }
}
