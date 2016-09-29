//
//  UIPanGestureRecognizer+Direction.swift
//  FlickTransition
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit

public enum Direction {
    case Up
    case Down
    case Left
    case Right
    
    var isX: Bool { return self == .Left || self == .Right }
    var isY: Bool { return !isX }
}

extension UIPanGestureRecognizer {
    
    public var direction: Direction? {
        let vel = velocity(in: view)
        let vertical = fabs(vel.y) > fabs(vel.x)
        switch (vertical, vel.x, vel.y) {
        case (true, _, let y) where y < 0: return .Up
        case (true, _, let y) where y > 0: return .Down
        case (false, let x, _) where x > 0: return .Right
        case (false, let x, _) where x < 0: return .Left
        default: return nil
        }
    }
}
