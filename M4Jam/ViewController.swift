//
//  ViewController.swift
//  M4Jam
//
//  Created by Ryann Consalo on 2017/07/03.
//  Copyright © 2017 Ryann Consalo. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: "https://app.m4jam.com/app/client/jobbers/sign-up/#login")
        webView.loadRequest(URLRequest(url: myURL!))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

