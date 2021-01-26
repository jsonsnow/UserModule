//
//  VipPulgin.swift
//  Alamofire
//
//  Created by chen liang on 2021/1/15.
//

import Foundation
import Moya

public class VipPlugin: Moya.PluginType {
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            if let data = (try? response.mapJSON()) as? [String: Any] {
                if let result = data[ResponseKeyType.result.rawValue] as? [String: Any] {
                    if let vip = result["vip_object"] as? [String: Any] {
                        NetConfig.config.vipClosure?(vip)
                    }
                }
            }
        default:
            #if DEBUG
            print("不处理")
            #endif
        }
    }
}
