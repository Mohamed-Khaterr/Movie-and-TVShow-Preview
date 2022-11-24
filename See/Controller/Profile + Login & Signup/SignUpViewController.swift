//
//  SginUpViewController.swift
//  See
//
//  Created by Khater on 11/1/22.
//

import UIKit
import WebKit

class SignUpViewController: UIViewController {
    
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        
        webView?.frame = view.bounds
        
        view.addSubview(webView!)
        
        let url = URL(string: "https://www.themoviedb.org/signup")
        
        webView?.load(URLRequest(url: url!))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        webView = nil
    }
}
