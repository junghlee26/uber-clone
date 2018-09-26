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
    var driverLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverOnTheWay = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = FIRAuth.auth()?.currentUser?.email {
            FIRDatabase.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                self.uberHasBeenCalled = true
                self.callUberButton.setTitle("Cancel Uber", for: .normal)
                FIRDatabase.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double,
                        let driverLon = rideRequestDictionary["driverLon"] as? Double {
                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                        self.driverOnTheWay = true
                        self.displayDriverAndRider()
                    }
                }
            }
        }
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        callUberButton.setTitle("Your Uber driver is \(roundedDistance)km away.", for: .normal)
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) / 10000
        let lonDelta = abs(driverLocation.longitude - userLocation.latitude) / 10000 
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "Your Location"
        map.addAnnotation(riderAnno)
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Your Driver"
        map.addAnnotation(driverAnno)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            
            if uberHasBeenCalled {
                displayDriverAndRider()
            } else {
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your Location"
                map.addAnnotation(annotation)
            }
        }
    }
    
    @IBAction func callUberTapped(_ sender: Any) {
        if !driverOnTheWay {
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
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        try? FIRAuth.auth()?.signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    



}
