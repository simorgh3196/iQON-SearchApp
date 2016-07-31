//
//  NSDate+TwitterHelper.swift
//  iQONSearchApp
//
//  Created by 早川智也 on 2016/07/30.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import Foundation

let TwitterDateFormat = "EEE MMM dd HH:mm:ss Z yyyy"

extension NSDate {
    private static let formatter: NSDateFormatter = {
        print("NSDateFormatter init")
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter
    }()
    
    static func dateFromString(date: String, format: String) -> NSDate? {
        
        formatter.dateFormat = format
        return formatter.dateFromString(date)
    }
    
    func toString() -> String {
        
        NSDate.formatter.dateFormat = NSLocalizedString("format_date", comment: "")
        return NSDate.formatter.stringFromDate(self)
    }
    
    func toString(format: String) -> String {
        
        NSDate.formatter.dateFormat = format
        return NSDate.formatter.stringFromDate(self)
    }
}
