//
//  SearchResponse.swift
//  iQONSearchApp
//
//  Created by 早川智也 on 2016/07/30.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import Foundation
import Himotoki


struct SearchResponse<Item: Decodable>: Decodable {
    let items: [Item]
    
    static func decode(e: Extractor) throws -> SearchResponse {
        return try SearchResponse(items: e <|| "statuses")
    }
}