//
//  RiderViewController.swift
//  Uber
//
//  Created by Junghoon Lee on 9/20/18.
//  Copyright © 2018 Junghoon Lee. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase

class RiderViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            map.setRegion(region, animated: true)
            map.removeAnnotations(map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your Location"
            map.addAnnotation(annotation)
        }
    }
    
    @IBAction func callUberTapped(_ sender: Any) {
        if let email = FIRAuth.auth()?.currentUser?.email {
            
            if uberHasBeenCalled {
                uberHasBeenCalled = false
                callUberButton.setTitle("Call an Uber", for: .normal)
                FIRDatabase.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                    snapshot.ref.removeValue()
                    FIRDatabase.database().reference().child("RideRequests").removeAllObservers()
                }
            } else {
                let riderRequestDictionary : [String:Any] = ["email":email, "lat":userLocation.latitude, "lon":userLocation.longitude]
                FIRDatabase.database().reference().child("RideRequests").childByAutoId().setValue(riderRequestDictionary)
                uberHasBeenCalled = true
                callUberButton.setTitle("Cancel Uber", for: .normal)
            }
        }
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        
    }
    



}
