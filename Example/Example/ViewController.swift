//
//  ViewController.swift
//  Example
//
//  Created by Remi Robert on 01/10/2016.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import FlickTransition

class ViewController: UIViewController {

    @IBOutlet weak var buttonSelection: UIButton!
    
    @IBAction func displayController(_ sender: AnyObject) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewverViewController") as! ViewverViewController
        controller.image = UIImage(named: "img")
        
        let rect = self.buttonSelection.frame
        
        FlickTransitionCoordinator.sharedCoordinator.presentViewController(controller, presentOriginFrame: rect)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
