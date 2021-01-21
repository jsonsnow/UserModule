//
//  NetConfig.swift
//  WGNet
//
//  Created by chen liang on 2021/1/19.
//

import Foundation

public class NetConfig: NSObject {
    public typealias HeadersClosure = (String) -> [String: String]?
    public typealias CallbackClosure = (_ data: WGConnectData) -> Void
    public typealias BaseUrlClosure = (String) -> String
    
    public private(set) var defaultHeades: [String: String]?
    public private(set) var defaultParams: [String: Any]?

    public private(set) var urlClosure: BaseUrlClosure?
    
    @objc public static let config: NetConfig = NetConfig.init()
    
    public override init() {
        super.init()
    }
}

//MARK: -- DefaultParams
extension NetConfig {
    
    @objc public func configDefaultHeaders(_ headers: [String: String]) {
        defaultHeades = headers
    }
    
    @objc public func configDefaultParams(_ params: [String: Any]) {
        defaultParams = params
    }
    
    @objc public func configBaseUrlClosure(_ urlClosure: @escaping BaseUrlClosure) {
        self.urlClosure = urlClosure
    }
    
}

