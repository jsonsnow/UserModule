//
//  Device+Extension.swift
//  Masonry
//
//  Created by chen liang on 2021/1/21.
//

import Foundation
import UIKit

@objc public extension UIDevice {
    
    
    var isPad: Bool {
        get {
            return self.userInterfaceIdiom == .pad
        }
    }
    
    var isPhone: Bool {
        get {
            return self.userInterfaceIdiom == .phone
        }
    }
    
    var isTv: Bool {
        get {
            return self.userInterfaceIdiom == .tv
        }
    }
    
    var isCarPlay: Bool {
        get {
            return self.userInterfaceIdiom == .carPlay
        }
    }
    
    var isSimulator: Bool {
        var result = false
        #if targetEnvironment(simulator)
            result = true
        #endif
        return result
    }
}

@objc public extension UIDevice {
    
    /// 是否刘海屏
    /// - Returns: result
    func iSiPhoneNotchScreen() -> Bool {
        var result = false
        if !self.isPhone {
            return result
        }
        if #available(iOS 11.0, *) {
            if let window = UIApplication.cl_keyWindow() {
                if window.safeAreaInsets.bottom > 0.0 {
                    result = true
                }
            }
        }
        return result
    }
}


