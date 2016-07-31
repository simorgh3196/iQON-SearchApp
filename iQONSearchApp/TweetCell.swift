//
//  TweetCell.swift
//  iQONSearchApp
//
//  Created by 早川智也 on 2016/07/30.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import UIKit


class TweetCell: UICollectionViewCell {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var screenNameLabel: UILabel!
    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = UIEdgeInsetsZero
        }
    }
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    var tweet: Tweet? {
        didSet {
            if let tweet = tweet {
                nameLabel.text = tweet.userName
                screenNameLabel.text = "@" + tweet.screenName
                textView.text = tweet.text
                likeCountLabel.text = String(tweet.likeCount)
                retweetCountLabel.text = String(tweet.retweetCount)
                dateLabel.text = tweet.createdAt
                
                textView.font = UIFont.systemFontOfSize(14)
            }
        }
    }
    
    
    
}
