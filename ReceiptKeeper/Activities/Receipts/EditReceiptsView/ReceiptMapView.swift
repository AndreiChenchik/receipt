//
//  ReceiptMapView.swift
//  ReceiptMapView
//
//  Created by Andrei Chenchik on 30/8/21.
//

import SwiftUI
import MapKit

struct ReceiptMapView: View {
    let region: MKCoordinateRegion

    struct Pin: Identifiable {
        let id = UUID()
        let region: MKCoordinateRegion
    }
    
    var body: some View {
        Map(coordinateRegion: .constant(region), annotationItems: [Pin(region: region)]) { item in
            MapPin(coordinate: item.region.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

//struct ReceiptMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReceiptMapView()
//    }
//}
