//
//  RecognizedContentLineView.swift
//  RecognizedContentLineView
//
//  Created by Andrei Chenchik on 26/8/21.
//

import SwiftUI

struct RecognizedContentLineView: View {
    var receipt: Receipt

    @EnvironmentObject var dataController: DataController

    var line: RecognizedContent.Line

    func lineIcon(for line: RecognizedContent.Line) -> String {
        switch line.contentType {
        case .total:
            return "sum"
        case .item:
            return "cart"
        case .address:
            return "mappin.and.ellipse"
        case .date:
            return "calendar.badge.clock"
        case .unknown:
            return "questionmark"
        case .venue:
            return "crown"
        }
    }

    func changeLineType(for line: RecognizedContent.Line, to contentType: RecognizedContent.Line.ContentType) {
        receipt.recognitionData = receipt.recognitionData?.withChangedLineContentType(for: line, to: contentType)
        dataController.saveIfNeeded()
    }

    var body: some View {
        Label {
            Text(line.text)
                .foregroundColor(.primary)
        } icon: {
            Menu {
                Button {
                    changeLineType(for: line, to: .item)
                } label: {
                    Label("Add to purchased items", systemImage: "cart")
                }

                Button {
                    changeLineType(for: line, to: .total)
                } label: {
                    Label("Use as total", systemImage: "sum")
                }

                Button {
                    changeLineType(for: line, to: .date)
                } label: {
                    Label("Extract purchase date", systemImage: "calendar.badge.clock")
                }

                Button {
                    changeLineType(for: line, to: .venue)
                } label: {
                    Label("Use as venue title", systemImage: "crown")
                }

                Button {
                    changeLineType(for: line, to: .address)
                } label: {
                    Label("Add to store address", systemImage: "mappin.and.ellipse")
                }

                Button {
                    changeLineType(for: line, to: .unknown)
                } label: {
                    Label("Don't use this line", systemImage: "xmark")
                }
            } label: {
                Image(systemName: lineIcon(for: line))
            }
        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: true, vertical: false)
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecognizedContentLineView()
//    }
//}
