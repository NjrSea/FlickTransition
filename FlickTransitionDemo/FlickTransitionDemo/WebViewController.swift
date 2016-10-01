//
//  WebViewController.swift
//  FlickTransitionDemo
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit
import FlickTransition

class WebViewController: UIViewController {

    fileprivate var webView: UIWebView = {
        let webView = UIWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private var closeButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Close", for: UIControlState.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(closeButton)
        for formatString in ["H:|-0-[webView]-0-|", "V:|-0-[webView]-0-|", "H:|-20-[button(50)]", "V:[button(40)]-0-|"] {
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: formatString, options: NSLayoutFormatOptions.directionLeadingToTrailing, metrics: nil, views: ["webView" : webView, "button" : closeButton]))
        }
        closeButton.addTarget(self, action: #selector(close), for: UIControlEvents.touchUpInside)
        let request = NSURLRequest(url: URL(string: "https://github.com")!)
        webView.loadRequest(request as URLRequest)
    }
    
    func close() {
        FlickTransitionCoordinator.sharedCoordinator.dismissViewControllerNoninteractively()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension WebViewController: FlickTransitionDelegate {
    
    func scrollView() -> UIScrollView? {
        return webView.scrollView
    }
    
    func useInteractiveDismiss() -> Bool {
        return true
    }
    
    func shouldBeginInteractiveDismiss() -> Bool {
        return !webView.isLoading
    }
    
}
