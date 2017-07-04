//
//  ViewController.swift
//  M4Jam
//
//  Created by Ryann Consalo on 2017/07/03.
//  Copyright © 2017 Ryann Consalo. All rights reserved.
//
//

import UIKit
import WebKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, WKUIDelegate, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    let locationManager = CLLocationManager()

    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://app.m4jam.com/app/client/jobbers/sign-up/#login")!
        webView.load(URLRequest(url: url))
        //webView.allowsBackForwardNavigationGestures = true
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 10000
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        print("disappearing")
        webView.evaluateJavaScript("document.getElementById('password').innerText") { (result, error) in
            if error != nil {
                print("no error")
            }
            if error == nil {
                print("error")
            }
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("disappearing")
        webView.evaluateJavaScript("document.getElementById('password').innerText") { (result, error) in
            if error != nil {
                print(result)
            }
            if error == nil {
                print(result)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get most recent coordinate
        let myCoor = locations[0]
        //get lat and lon
        let myLat = myCoor.coordinate.latitude
        let myLon = myCoor.coordinate.longitude
        let myCoor2D = CLLocationCoordinate2D(latitude: myLat, longitude: myLon)
        
        print("location changed")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func loadURL() {
        let urlString = "https://app.m4jam.com/app/client/jobbers/sign-up/#login"
        guard let url = NSURL(string: urlString) else {return}
        let request = NSMutableURLRequest(url:url as URL)
        webView.load(request as URLRequest)
    }
    
}

