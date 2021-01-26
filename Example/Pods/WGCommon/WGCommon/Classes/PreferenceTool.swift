//
//  PreferenceTool.swift
//  WGCommon
//
//  Created by chen liang on 2021/1/18.
//

import Foundation

 public class PreferenceTool: NSObject {
    
    @objc static public func set(value: Any?, with key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    @objc static public func getValue(by key: String) -> Any? {
        UserDefaults.standard.value(forKey: key)
    }
    
    @objc static public func setValueInDefaultGroup(_ value: Any?, key: String) {
        setValueInGroup(value, key: key)
    }
    
    @objc static public func getValueInDefaultGroup(with key: String) -> Any? {
        return getValueInGroupWithKey(key)
    }
    
    static public func setValueInGroup(_ value: Any?, key: String, suiteName: String = "group.com.sd.StoreSystem.12.ShareExtension") -> Void {
        guard let userDefaults = UserDefaults.init(suiteName: suiteName) else {
            return
        }
        userDefaults.setValue(value, forKey: key)
        userDefaults.synchronize()
    }
    
    static public func getValueInGroupWithKey(_ key: String, suiteName: String = "group.com.sd.StoreSystem.12.ShareExtension") -> Any? {
        guard let userDefaults = UserDefaults.init(suiteName: suiteName) else {
            return nil
        }
        return userDefaults.object(forKey: key)
    }
    
    
}
