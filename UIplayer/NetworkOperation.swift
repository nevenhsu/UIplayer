//
//  NetworkOperation.swift
//  UIplayer
//
//  Created by Neven on 18/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import Foundation
import SystemConfiguration

class NetworkOperation {
    let queryURL: URL!
    lazy var config: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.config)
    var fail: Bool
    
    init(url: URL) {
        queryURL = url
        fail = false
    }
    
    func downloadJSON(completion: @escaping (Data?) -> Void) {
        
        let resquest: URLRequest = URLRequest(url: queryURL)
        let dataTask = session.dataTask(with: resquest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    self.fail = false
                    completion(data)
                    
                default:
                    self.fail = true
                    completion(nil)
                    print("httpResponse is error: \(httpResponse.statusCode)")
                }
            }
        }
        dataTask.resume()
    }
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
}
