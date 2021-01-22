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

class UserModule: NSObject, WGUserModuleService, BifrostModuleProtocol {
    
    func saveLoginUserInfo(_ info: [AnyHashable : Any] = [:]) {
        
    }
    
    func saveUserToken(_ token: String) {
        
    }
    
    func userToken() -> String? {
        return PreferenceTool.getValue(by: "") as? String
    }
    
    func albumId() -> String? {
        guard let info = PreferenceTool.getValueInDefaultGroup(with: "log_in_info") as? [String: Any] else {
            return nil
        }
        return info["shop_id"] as? String
        
    }
    
    static func sharedInstance() -> Self! {
        return instance as? Self
    }
    
    static let instance: UserModule = UserModule.init()
    
    private override init() {
        super.init()
    }
    
    func setup() {
    
    }
    
    
}
