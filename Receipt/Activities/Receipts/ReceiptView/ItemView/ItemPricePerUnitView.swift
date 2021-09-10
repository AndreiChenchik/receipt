//
//  ItemPricePerUnitView.swift
//  ItemPricePerUnitView
//
//  Created by Andrei Chenchik on 10/9/21.
//

import SwiftUI

struct ItemPricePerUnitView: View {
    var text: String
    var icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)

            Text(text)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(5)
        .background(
            Color(.systemGray6)
                .opacity(0.5)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
    }
}

struct ItemPricePerUnitView_Previews: PreviewProvider {
    static var previews: some View {
        ItemPricePerUnitView(text: "10 EUR per Kilo", icon: "chart.bar.fill")
    }
}
