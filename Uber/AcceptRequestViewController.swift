//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by Junghoon Lee on 9/21/18.
//  Copyright © 2018 Junghoon Lee. All rights reserved.
//

import UIKit
import MapKit

class AcceptRequestViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var requestEmail = ""
    var requestLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
        
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        
    }
    

}
