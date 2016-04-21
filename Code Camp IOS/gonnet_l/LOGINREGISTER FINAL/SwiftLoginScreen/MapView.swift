//
//  MapView.swift
//  JolicutREGLOG
//
//  Created by Guillaume FORESTIER on 21/04/16.
//  Copyright © 2016 Forestier Guillaume. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import Foundation

class MapView: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var Carte: MKMapView!
    @IBOutlet var webView: UIWebView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.Carte.showsUserLocation = true
        
        activation()
    }
    
    func activation() {
        let lien = NSURL(string: "https://maps.googleapis.com/maps/api/place/radarsearch/json?location=48.816,2.386&radius=500&types=hair_care&key=AIzaSyASXpUDvcbPmXXB_GLQD6KtGYfOeIh7jIk")
        let request = NSURLRequest(URL: lien!)
        self.webView.loadRequest(request)
        let jsonData = NSData(contentsOfURL: lien!)
        do {
            if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSDictionary {
                let results = convertedJsonIntoDict.valueForKey("results") as? NSArray
                for item in results!
                {
                    let lat = item.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lat") as! CLLocationDegrees
                    let lng = item.valueForKey("geometry")?.valueForKey("location")?.valueForKey("lng") as! CLLocationDegrees
                    let pos = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    let dropPin = MKPointAnnotation()
                    dropPin.coordinate = pos
                    dropPin.title = "Test"
                    Carte.addAnnotation(dropPin)
                    print(pos)
                }
            }
        }  catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations places: [CLLocation]) {
        
        let place = places.last
        
        let point = CLLocationCoordinate2D(latitude: place!.coordinate.latitude, longitude: place!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: point, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.Carte.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
        
        print(places)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError erreur: NSError) {
        print("Erreurs : " + erreur.localizedDescription)
    }
    
}