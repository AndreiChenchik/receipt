//
//  MapView.swift
//  MapView
//
//  Created by Andrei Chenchik on 30/8/21.
//

import SwiftUI
import MapKit

struct MapView: View {
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

struct ReceiptMapView_Previews: PreviewProvider {
    static let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5),
                                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    static var previews: some View {
        Form {
            MapView(region: region)
        }
    }
}
