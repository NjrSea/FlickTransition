//
//  ViewverViewController.swift
//  Example
//
//  Created by Remi Robert on 01/10/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import FlickTransition

class ViewverViewController: UIViewController, FlickTransitionDelegate {

    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func close(_ sender: AnyObject) {
        FlickTransitionCoordinator.sharedCoordinator.dismissViewControllerNoninteractively(Direction.Up)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = self.image
    }
    
    public func scrollView() -> UIScrollView? {
        return nil
    }
    
    public func useInteractiveDismiss() -> Bool {
        return true
    }
    
    public func shouldBeginInteractiveDismiss() -> Bool {
        return true
    }
}
