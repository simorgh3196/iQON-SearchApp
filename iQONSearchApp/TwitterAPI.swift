//
//  APIClient.swift
//  iQONSearchApp
//
//  Created by 早川智也 on 2016/07/15.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import Foundation
import Accounts
import Social


enum Results<T, Error: ErrorType> {
    case success(T)
    case failure(Error)
}

enum APIErrorType: ErrorType {
    case requestError(ErrorType)
    case responseError(String)
    case parseError(ErrorType)
}


final class TwitterAPI {
    
    static func sendSearchRequest(account account: ACAccount, query: String, sinceId: Int? = nil, maxId: Int? = nil, count: Int = 100, completion: (Results<SearchResponse<Tweet>, APIErrorType>) -> ()) {
        
        var param: [String : AnyObject] = ["q" : query, "count" : String(count)]
        if let maxId = maxId {
            param["max_id"] = String(maxId)
        }
        if let sinceId = sinceId {
            param["since_id"] = String(sinceId)
        }
        
        let url = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: param)
        request.account = account
        
        print("request count:", count)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            request.performRequestWithHandler { data, response, error in
                
                if let error = error {
                    completion(.failure(.responseError(error.localizedDescription)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.responseError("No data")))
                    return
                }
                
                do {
                    let json = try NSJSONSerialization
                        .JSONObjectWithData(data, options: .AllowFragments) as! [String : AnyObject]
                    
                    let tweets = try SearchResponse<Tweet>.decodeValue(json)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(.success(tweets))
                    })
                    
                } catch let error {
                    completion(.failure(.parseError(error)))
                }
            }
        })
    }
        
}
