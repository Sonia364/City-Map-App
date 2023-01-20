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
    var locationsArr = [CLLocationCoordinate2D]()
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
            
            // add coordinate to locationArr
            
            locationsArr.append(coordinate)
            
        }
        
        if( dropPinCount == 3){
            addPolygon()
            calculateDistanceBetweenMapPoints()
            
        }
        
        dropPinCount += 1
        //destination = coordinate
    }
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            
            return nil
            
        }else{
            let numberRegEx  = ".*[0-9]+.*"
            let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
            let containsNumber = testCase.evaluate(with: annotation.title)
            
            if(containsNumber){
                return nil
            }
            else{
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
                annotationView.animatesDrop = true
                annotationView.pinTintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                annotationView.canShowCallout = true
                return annotationView
            }
        }
        
        
        
    }
    
    //MARK: - polygon method
    func addPolygon() {
        let polygon = MKPolygon(coordinates: locationsArr, count: locationsArr.count)
        map.addOverlay(polygon)
    }
    
//    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.orange
            //rendrer.lineDashPattern = transportVal == .walking ? [0,10]: []
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
    
    func calculateDistanceBetweenMapPoints(){
        
        
        let coordinate1 = CLLocation(latitude: locationsArr[0].latitude, longitude: locationsArr[0].longitude)
        let coordinate2 = CLLocation(latitude: locationsArr[1].latitude, longitude: locationsArr[1].longitude)
        let coordinate3 = CLLocation(latitude: locationsArr[2].latitude, longitude: locationsArr[2].longitude)

        let distanceInMetersFirst = Int(coordinate1.distance(from: coordinate2))
        let distanceInMetersSecond = Int(coordinate2.distance(from: coordinate3))
        let distanceInMetersThird = Int(coordinate3.distance(from: coordinate1))
        
        // display distance between first two points
        
        let latitudeMidOne = ((locationsArr[0].latitude + locationsArr[1].latitude) / 2)
        let longitudeMidOne = ((locationsArr[0].longitude + locationsArr[1].longitude) / 2)
        
        let location1 = CLLocationCoordinate2D(latitude: latitudeMidOne, longitude: longitudeMidOne)
        let annotation1 = MKPointAnnotation()
        annotation1.title = String(distanceInMetersFirst) + " m"
        annotation1.coordinate = location1
        map.addAnnotation(annotation1)
        
        // display distance between second third points
        
        let latitudeMidTwo = ((locationsArr[1].latitude + locationsArr[2].latitude) / 2)
        let longitudeMidTwo = ((locationsArr[1].longitude + locationsArr[2].longitude) / 2)
        
        let location2 = CLLocationCoordinate2D(latitude: latitudeMidTwo, longitude: longitudeMidTwo)
        let annotation2 = MKPointAnnotation()
        annotation2.title = String(distanceInMetersSecond) + " m"
        annotation2.coordinate = location2
        map.addAnnotation(annotation2)
        
        // display distance between second third points
        
        let latitudeMidThree = ((locationsArr[2].latitude + locationsArr[0].latitude) / 2)
        let longitudeMidThree = ((locationsArr[2].longitude + locationsArr[0].longitude) / 2)
        
        let location3 = CLLocationCoordinate2D(latitude: latitudeMidThree, longitude: longitudeMidThree)
        let annotation3 = MKPointAnnotation()
        annotation3.title = String(distanceInMetersThird) + " m"
        annotation3.coordinate = location3
        map.addAnnotation(annotation3)
        
        
    }
    


}

