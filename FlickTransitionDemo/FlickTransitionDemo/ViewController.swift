//
//  ViewController.swift
//  FlickTransitionDemo
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit
import FlickTransition

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var rect = tableView.rectForRow(at: indexPath)
        rect = tableView.convert(rect, to: view)
        FlickTransitionCoordinator.sharedCoordinator.presentViewController(WebViewController(), presentOriginFrame: rect)
    }
}

