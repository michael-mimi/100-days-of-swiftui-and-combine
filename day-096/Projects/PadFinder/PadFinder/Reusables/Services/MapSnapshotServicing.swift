//
//  MapSnapshotServicing.swift
//  PadFinder
//
//  Created by CypherPoet on 1/28/20.
// ✌️
//


import SwiftUI
import MapKit
import Combine


protocol MapSnapshotServicing: class {
    var snapshotOptions: MKMapSnapshotter.Options { get }
    var queue: DispatchQueue { get }
    
    func takeSnapshot(
        with size: CGSize,
        at coordinate: CLLocationCoordinate2D,
        latitudeSpan: CLLocationDegrees,
        longitudeSpan: CLLocationDegrees
    ) -> Future<MKMapSnapshotter.Snapshot, Error>
}


extension MapSnapshotServicing {
    
    func takeSnapshot(
        with size: CGSize,
        at coordinate: CLLocationCoordinate2D,
        latitudeSpan: CLLocationDegrees = 0.15,
        longitudeSpan: CLLocationDegrees = 0.15
    ) -> Future<MKMapSnapshotter.Snapshot, Error> {
        let span = MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan)
        
        snapshotOptions.region = MKCoordinateRegion(
            center: coordinate,
            span: span
        )
        
        snapshotOptions.size = size
        
        let snapshotter = MKMapSnapshotter(options: snapshotOptions)
        
        return Future { promise in
            snapshotter.start(with: self.queue) { (snapshot, error) in
                guard error == nil else {
                    return promise(.failure(error!))
                }
                
                guard let snapshot = snapshot else {
                    preconditionFailure("No snapshot returned despite snapshotter completing without error.")
                }
                
                return promise(.success(snapshot))
            }
        }
    }
}

