//
//  ItemTitleView.swift
//  ItemTitleView
//
//  Created by Andrei Chenchik on 10/9/21.
//

import SwiftUI

struct ItemTitleView: View {
    @Binding var title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                Text(title)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(Font.body.weight(.bold))
                    .opacity(0)
                    .layoutPriority(1)

                TextEditor(text: $title)
                    .font(Font.body.weight(.bold))
                    .padding(.vertical, -9)
                    .padding(.horizontal, -5)
            }
            .padding(.horizontal, 5)

            Divider()
        }
    }
}

struct ItemTitleView_Previews: PreviewProvider {
    static var previews: some View {
        ItemTitleView(title: .constant("Item Title"))
    }
}
