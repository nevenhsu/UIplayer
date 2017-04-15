//
//  NetworkOperation.swift
//  UIplayer
//
//  Created by Neven on 18/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import Foundation

class NetworkOperation {
    let queryURL: URL!
    lazy var config: URLSessionConfiguration = URLSessionConfiguration.default
    lazy var session: URLSession = URLSession(configuration: self.config)
    var fail: Bool
    
    init(url: URL) {
        queryURL = url
        fail = false
    }
    
    func downloadJSON(completion: @escaping ([String: AnyObject]) -> Void) {
        let resquest: URLRequest = URLRequest(url: queryURL)
        let dataTask = session.dataTask(with: resquest) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        self.fail = false
                        completion(json as! [String : AnyObject])
                    } catch let error as NSError {
                        self.fail = true
                        print(error.debugDescription)
                    }
                default:
                    self.fail = true
                    print("httpResponse is error: \(httpResponse.statusCode)")
                }
            }
        }
        dataTask.resume()
    }
    
}
