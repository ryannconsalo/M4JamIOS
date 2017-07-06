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
    let userContentController = WKUserContentController()
    
    let locationManager = CLLocationManager()

    override func loadView() {
        super.loadView()
        
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        //userContentController.add(self, name: "userLogin")
        
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var request = URLRequest(url: URL(string: "https://app.m4jam.com//api-token/")!)
        request.httpMethod = "POST"
        let postString = "username=27649862819&password=213emily"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)!")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            /* for (key, value) in responseString {
             if (key as! String == "token") {
             print(value)
             }
             }*/
            print("responseString = \(responseString!)")
            
            let responseStringArray = responseString?.components(separatedBy: "\"")
            print(responseStringArray![3])
            // Save user token in user defaults for key "token"
            UserDefaults.standard.set(responseStringArray![3], forKey: "token")
            
        }
        task.resume()

        
        //let configuration = WKWebViewConfiguration()
        //let controller = WKUserContentController()
        
        //controller.add(WKScriptMessageHandler: self, name: 'JSListener')
        //configuration.userContentController = controller
        
        let url = URL(string: "https://app.m4jam.com/app/client/jobbers/sign-up/#login")!
        webView.load(URLRequest(url: url))
        //webView.allowsBackForwardNavigationGestures = true
        
        /*
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 10000
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        print("disappearing")
        webView.evaluateJavaScript("document.getElementById('toggle-sign-up').textContent") { (result, error) in
            if error != nil {
                print(result)
            }
            if error == nil {
                print(result)
            }
        }
        
        
*/
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        /*print("disappearing")
        webView.evaluateJavaScript("document.getElementById('password').innerText") { (result, error) in
            if error != nil {
                print(result)
            }
            if error == nil {
                print(result)
            }
        }
 */
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

/*
    func loadURL() {
        let urlString = "https://app.m4jam.com/app/client/jobbers/sign-up/#login"
        guard let url = NSURL(string: urlString) else {return}
        let request = NSMutableURLRequest(url:url as URL)
        webView.load(request as URLRequest)
    }
 */
    
    
    
}

