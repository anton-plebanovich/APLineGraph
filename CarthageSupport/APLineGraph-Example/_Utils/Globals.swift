//
//  Globals.swift
//  APLineGraph
//
//  Created by Anton Plebanovich on 3/10/19.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit


let g: Globals = Globals()

final class Globals {
    
    // ******************************* MARK: - Typealiases
    
    /// Closure that takes Void and returns Void.
    public typealias SimpleClosure = () -> Void
    
    // ******************************* MARK: - Animations
    
    func animate(animations: @escaping SimpleClosure) {
        animate(animations: animations, completion: nil)
    }
    
    func animate(_ duration: TimeInterval, animations: @escaping SimpleClosure) {
        animate(duration, animations: animations, completion: nil)
    }
    
    func animate(_ duration: TimeInterval, options: UIView.AnimationOptions, animations: @escaping SimpleClosure) {
        animate(duration, options: options, animations: animations, completion: nil)
    }
    
    func animate(_ duration: TimeInterval = 0.3, delay: TimeInterval = 0, options: UIView.AnimationOptions = .beginFromCurrentState, animations: @escaping SimpleClosure, completion: ((Bool) -> ())? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
    }
    
    // ******************************* MARK: - Dispatch
    
    /// Executes a closure in a default queue after requested seconds. Uses GCD.
    /// - parameters:
    ///   - delay: number of seconds to delay
    ///   - closure: the closure to be executed
    func asyncBg(_ delay: TimeInterval = 0, closure: @escaping SimpleClosure) {
        let delayTime: DispatchTime = .now() + delay
        DispatchQueue.global(qos: .default).asyncAfter(deadline: delayTime, execute: {
            closure()
        })
    }
    
    /// Executes a closure if already in background or dispatch asyn in background. Uses GCD.
    /// - parameters:
    ///   - closure: the closure to be executed
    func performInBackground(_ closure: @escaping SimpleClosure) {
        if Thread.isMainThread {
            DispatchQueue.global(qos: .default).async {
                closure()
            }
        } else {
            closure()
        }
    }
    
    /// Executes a closure in the main queue after requested seconds asynchronously. Uses GCD.
    /// - parameters:
    ///   - delay: number of seconds to delay
    ///   - closure: the closure to be executed
    func asyncMain(_ delay: TimeInterval = 0, closure: @escaping SimpleClosure) {
        let delayTime: DispatchTime = .now() + delay
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            closure()
        }
    }
    
    /// Executes a closure if already in main or dispatch asyn in main. Uses GCD.
    /// - parameters:
    ///   - closure: the closure to be executed
    func performInMain(_ closure: @escaping SimpleClosure) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async { closure() }
        }
    }
}
