//
//  UserModule.swift
//  UserModule
//
//  Created by chen liang on 2021/1/22.
//

import Foundation
import Mediator
import WGCommon
import WGRouter

public class UserModuleImp: NSObject {
    
    @objc public static let instance: UserModuleImp = UserModuleImp.init()
    var js_develop: String? = nil
    var user_token: String? = nil
    
    @objc public func jsDevelop() -> String {
        if js_develop != nil {
            return js_develop!
        }
        if let value = PreferenceTool.getValueInGroupWithKey("js_develop") as? String {
            return value
        }
        return "0"
    }
    
    @objc public func setJsDevelop(with value: Any?) -> Void {
        guard let _value = value else { return  }
        js_develop = "\(_value)"
        PreferenceTool.setValueInGroup(js_develop!, key: "js_develop")
    }
    
    @objc public func saveLoginUserInfo(_ info: [AnyHashable : Any] = [:]) {
        PreferenceTool.setValueInDefaultGroup(info, key: "log_in_info")
    }
    
    @objc public func saveUserToken(_ token: String) {
        user_token = token
        PreferenceTool.set(value: token, with: "login_token")
        PreferenceTool.setValueInDefaultGroup(token, key: "share_token")
    }
    
    @objc public func userToken() -> String? {
        if let token = user_token {
            return token
        }
        return PreferenceTool.getValue(by: "login_token") as? String
    }
    
    @objc public func albumId() -> String? {
        guard let info = PreferenceTool.getValueInDefaultGroup(with: "log_in_info") as? [String: Any] else {
            return nil
        }
        return info["shop_id"] as? String
    }
    
    @objc public func clear() {
        js_develop = nil
        user_token = nil
        PreferenceTool.setValueInGroup(nil, key: "share_token")
        PreferenceTool.set(value: nil, with: "login_token")
        PreferenceTool.setValueInGroup(nil, key: "js_develop")
    }
    
    private override init() {
        super.init()
        Bifrost.registerService(WGUserModuleService.self, withModule: UserModule.self)
    }    
    
}
