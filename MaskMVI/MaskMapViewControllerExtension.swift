//
//  MaskMapViewControllerExtension.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/17.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import MapKit


extension MaskMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            updateMyLocation(lastLocation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.overlays.forEach {
            mapView.removeOverlay($0)
        }
        
        guard let annoCoord = view.annotation?.coordinate else { return }
        
        let startItem = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
        let endItem = MKMapItem(placemark: MKPlacemark(coordinate: annoCoord))
        
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = startItem
        directionRequest.destination = endItem
        directionRequest.transportType = .walking
        
        let direction = MKDirections(request: directionRequest)
        
        
        direction.calculate { (res, err) in
            
            guard let res = res else { return }
            
            let route = res.routes[0]
                        
            self.expectedTime.onNext("도보 \(Int((route.expectedTravelTime / 60).rounded())) 분 거리")
            
            mapView.addOverlays([route.polyline], level: .aboveRoads)
            
            let rekt = route.polyline.boundingMapRect
            mapView.setRegion(MKCoordinateRegion(rekt), animated: true)
            
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polylines = mapView.overlays(in: .aboveRoads).filter { $0 is MKPolyline } as! [MKPolyline]
        
        guard let line = polylines.first else { return MKOverlayRenderer() }
        
        let lineRenderer = MKPolylineRenderer(polyline: line)
        
        lineRenderer.strokeColor = .systemTeal
        lineRenderer.lineWidth = 5
        
        return lineRenderer
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation.isKind(of: MKUserLocation.self)) else { return nil }
        
        let annoV = MaskAnnotationView(annotation: annotation, reuseIdentifier: "hi")
        
        annoV.canShowCallout = true
        annoV.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        annoV.backgroundColor = .white
        annoV.layer.cornerRadius = annoV.frame.width / 2
        
        
        if let anno = annotation as? MaskAnno {
            annoV.setColor(status: anno.maskStatus ?? "empty")
            return annoV
        } else {
            return nil
        }
    }
}
