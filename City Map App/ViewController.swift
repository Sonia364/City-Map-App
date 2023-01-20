//
//  ViewController.swift
//  City Map App
//
//  Created by Sonia Nain on 2023-01-19.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager = CLLocationManager()
    //var destination: CLLocationCoordinate2D!
    @IBOutlet weak var map: MKMapView!
    
    var dropPinCount = 1
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        map.isZoomEnabled = true
        map.showsUserLocation = true
        map.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
      
        addSingleTap()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "Your Location", subtitle: "you are here")
        
    }
    
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, subtitle: String) {
        // 2 - define delta latitude and delta longitude for the span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        // 3 - creating the span and location coordinate and finally the region
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 4 - set region for the map
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
        
    }
    
    //MARK: - single tap func
    func addSingleTap() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        singleTap.numberOfTapsRequired = 1
        map.addGestureRecognizer(singleTap)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        if(dropPinCount <= 3){
            // add annotation
            let touchPoint = sender.location(in: map)
            let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
            let annotation = MKPointAnnotation()
            let loc: CLLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            var address = ""
            CLGeocoder().reverseGeocodeLocation(loc) { (placemarks, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let placemark = placemarks?[0] {
                        
                        if placemark.locality != nil {
                            address += placemark.locality! + "\n"
                        }
                        
                        annotation.title = address
                        
                    }
                    
                }
            }
            
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
        }
        
        dropPinCount += 1
        
        //destination = coordinate
    }
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        annotationView.animatesDrop = true
        annotationView.pinTintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        annotationView.canShowCallout = true
        return annotationView
        
    }
    
//    //MARK: - callout accessory control tapped
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let alertController = UIAlertController(title: "Your Favorite", message: "A nice place to visit", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//        present(alertController, animated: true, completion: nil)
//    }
//
//    //MARK: - rendrer for overlay func
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is MKCircle {
//            let rendrer = MKCircleRenderer(overlay: overlay)
//            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
//            rendrer.strokeColor = UIColor.green
//            rendrer.lineWidth = 2
//            return rendrer
//        } else if overlay is MKPolyline {
//            let rendrer = MKPolylineRenderer(overlay: overlay)
//            rendrer.strokeColor = UIColor.orange
//            //rendrer.lineDashPattern = transportVal == .walking ? [0,10]: []
//            rendrer.lineWidth = 3
//            return rendrer
//        } else if overlay is MKPolygon {
//            let rendrer = MKPolygonRenderer(overlay: overlay)
//            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
//            rendrer.strokeColor = UIColor.yellow
//            rendrer.lineWidth = 2
//            return rendrer
//        }
//        return MKOverlayRenderer()
//    }
    
    


}

