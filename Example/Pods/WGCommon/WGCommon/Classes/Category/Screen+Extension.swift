//
//  Screen+Extension.swift
//  UserModule
//
//  Created by chen liang on 2021/1/23.
//

import Foundation
import UIKit

@objc public extension UIScreen {
    class func width() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    class func height() -> CGFloat {
        return UIScreen.main.bounds.height
    }
}
