//
//  UserBundleLoad.swift
//  UserModule
//
//  Created by chen liang on 2021/1/23.
//

import Foundation
import Mediator

public class UserBundleLoad: ModuleBundle {
    public override class func bundle(withName bundleName: String!) -> Bundle! {
        let bundle = Bundle.init(for: self)
        let path = bundle.path(forResource: bundleName, ofType: ".bundle")!
        return Bundle.init(path: path)!
    }
    public override class func bundle() -> Bundle! {
        return self.bundle(withName: "UserModule")
    }
}
