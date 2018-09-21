//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Junghoon Lee on 9/20/18.
//  Copyright © 2018 Junghoon Lee. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {

    var rideRequest : [FIRDataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        FIRDatabase.database().reference().child("RideRequests").observe(.childAdded) { (snapshopt) in
            self.rideRequest.append(snapshopt)
            self.tableView.reloadData()
        }
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequest.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        let snapshot = rideRequest[indexPath.row]
         if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
            if let email = rideRequestDictionary["email"] as? String {
                if let lat = rideRequestDictionary["lat"] as? Double,
                    let lon = rideRequestDictionary["lon"] as? Double {
                
                    let riderCLocation = CLLocation(latitude: lat, longitude: lon)
                    let driverCLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                    
                    let distance = driverCLocation.distance(from: riderCLocation) / 1000
                    let rounded = round(distance * 100) / 100
                    print(distance, rounded)
                    cell.textLabel?.text = "\(email) - \(rounded)km away"
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequest[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController {
            if let snapshot = sender as? FIRDataSnapshot {
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let email = rideRequestDictionary["email"] as? String,
                        let lat = rideRequestDictionary["lat"] as? Double,
                        let lon = rideRequestDictionary["lon"] as? Double {
                        acceptVC.requestEmail = email
                        acceptVC.requestLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }    
                }
            }
        }
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        try? FIRAuth.auth()?.signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
   
}
