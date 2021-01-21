//
//  UIApplication+Exten.swift
//  WGCommon
//
//  Created by chen liang on 2021/1/21.
//

import Foundation
import UIKit

extension UIApplication {
    static func cl_keyWindow() -> UIWindow? {
        let sharedSelector = NSSelectorFromString("sharedApplication")
        if UIApplication.responds(to: sharedSelector) {
            let shared = UIApplication.perform(sharedSelector)
            let res = shared?.takeUnretainedValue() as! UIApplication
             return res.keyWindow
        }
        return nil
    }
}
