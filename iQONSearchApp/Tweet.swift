//
//  Tweet.swift
//  iQONSearchApp
//
//  Created by 早川智也 on 2016/07/15.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import Foundation
import Himotoki


struct Tweet: Decodable {
    let statusId: Int
    let screenName: String
    let userName: String
    let userIconUrl: NSURL
    let createdAt: String
    let text: String
    let likeCount: Int
    let retweetCount: Int
    
    
    static func decode(e: Extractor) throws -> Tweet {
        
        let URLTransformer = Transformer<String, NSURL> { URLString throws -> NSURL in
            let url = URLString.stringByReplacingOccurrencesOfString("_normal", withString: "")
            if let URL = NSURL(string: url) {
                return URL
            }
            
            throw customError("Invalid URL string: \(URLString)")
        }
        
        let DateTransformaer = Transformer<String, String> { DateString throws -> String in
            let date = NSDate.dateFromString(DateString, format: TwitterDateFormat)
            return date!.toString("MM/dd HH:mm")
        }
        
        return try Tweet(
            statusId    : e <| "id",
            screenName  : e <| ["user", "screen_name"],
            userName    : e <| ["user", "name"],
            userIconUrl : try URLTransformer.apply(e <| ["user", "profile_image_url_https"]),
            createdAt   : try DateTransformaer.apply(e <| "created_at"),
            text        : e <| "text",
            likeCount   : e <| "favorite_count",
            retweetCount: e <| "retweet_count"
        )
    }
}