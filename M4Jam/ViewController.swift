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

class ViewController: UIViewController, CLLocationManagerDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    let locationManager = CLLocationManager()

    // Set view to webView
    override func loadView() {
        super.loadView()
    
        // Create contentController and configuration
        let contentController = WKUserContentController();
        contentController.add (
            self,
            name: "userLogin"
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // Set bounds and configuration to webView
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }
    
    
    // Put username and password entered into user defaults when message received from JavaScript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "userLogin") {
            print ("Launch my stuff")
            
            let dict = message.body as! [String:AnyObject]
            let username = dict["username"] as! String
            let password = dict["password"] as! String
            
            print(username)
            print(password)
            UserDefaults.standard.setValue(username, forKey: "username")
            UserDefaults.standard.setValue(password, forKey: "password")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // LOCATION UPDATES
        // Set location manager settings
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // Set accuracy to within one km in order to save battery
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Will call location manager function when distance changes more than 10 km (10000 m)
        locationManager.distanceFilter = 100
        
        // Start updating location if allowed
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        // Set url for webView and load page
        let url = URL(string: "https://app.m4jam.com/app/client/jobbers/sign-up/#login")!
        webView.load(URLRequest(url: url))
        
    }
    
    
    // Once page is loaded, add JavaScript and evaluate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let scriptURL = Bundle.main.path(forResource: "m4jam", ofType: "js")
        var scriptContent = ""
        do {
            scriptContent = try String(contentsOfFile: scriptURL!, encoding: String.Encoding.utf8)
            print("script")
        } catch {
            print("Cannot load file")
        }
        
        webView.evaluateJavaScript(scriptContent, completionHandler:  {
            (result: Any?, error: Error?)
            in
            if error == nil {
                print ("execution successful")
            }
            else {
                print("unsuccessful \(error)")
            }
        })

    }
    
    
    // LOCATION UPDATES
    // Called when location changes more than distance filter
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get most recent coordinate
        let myCoor = locations[0]
        //get lat and lon
        let myLat = myCoor.coordinate.latitude
        let myLon = myCoor.coordinate.longitude
        let myCoor2D = CLLocationCoordinate2D(latitude: myLat, longitude: myLon)
        
        print("location changed")
        // When location changes, get token from API
        var post = "username="
        if (UserDefaults.standard.value(forKey: "username") != nil) {
            post += UserDefaults.standard.value(forKey: "username") as! String
            post += "&password="
            post += UserDefaults.standard.value(forKey: "password") as! String
            print(post)
        }
        var request = URLRequest(url: URL(string: "https://app.m4jam.com//api-token/")!)
        request.httpMethod = "POST"
        request.httpBody = post.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Print error if error exists
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            // Print status code if it is not 200
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)!")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let responseStringArray = responseString?.components(separatedBy: "\"")
            // Save user token in user defaults for key "token"
            UserDefaults.standard.set(responseStringArray![3], forKey: "token")
            print(UserDefaults.standard.value(forKey: "token")!)
            
        }
        task.resume()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   }


