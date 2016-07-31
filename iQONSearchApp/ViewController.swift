//
//  ViewController.swift
//  iQONSearchApp
//
//  Created by 早川智也 on 2016/07/15.
//  Copyright © 2016年 simorgh. All rights reserved.
//

import UIKit
import Accounts
import SwiftyAlert


// MARK: - ViewController -

class ViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var loginButton: UIButton! {
        didSet { loginButton.layer.cornerRadius = 10 }
    }
    private var refreshControl: UIRefreshControl!
    private var twAccount: ACAccount?
    private var tweets: [Tweet] = []
    private var isLoading: Bool = false {
        didSet { UIApplication.sharedApplication().networkActivityIndicatorVisible = isLoading }
    }
    private var canSearch: Bool = true {
        didSet {
            if !canSearch {
                Alert(title: "検索上限に達しました。\n現在 \(tweets.count)件").addOk().show(self)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), forControlEvents: .ValueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    @IBAction private func tappedLoginButton(sender: UIButton) {
        sendSearchRequest()
    }
    
    private dynamic func pullToRefresh(sender: UIRefreshControl) {
        
        if 50..<1000 ~= tweets.count {
            let count = min(1000 - tweets.count, 100)
            sendSearchRequest(sinceId: tweets.first?.statusId, count: count)
        } else {
            Alert(title: "1000件に達しています。").addOk().show(self)
        }
    }
    
    private func sendSearchRequest(sinceId sinceId: Int? = nil, maxId: Int? = nil, count: Int = 100) {
        
        guard let account = twAccount else {
            selectTwitterAccount { [weak self] in
                self?.sendSearchRequest()
                self?.loginButton.hidden = true
            }
            return
        }
        
        if isLoading || !canSearch {
            return
        } else {
            isLoading = true
        }
        
        let query = "iQON" //"iQON exclude:nativeretweets"
        TwitterAPI.sendSearchRequest(account: account,
                                     query: query,
                                     sinceId: sinceId,
                                     maxId: maxId,
                                     count: count)
        { result in
            self.refreshControl.endRefreshing()
            switch result {
            case .success(let response):
                print("Search success. [\(response.items.count)]")
                self.tweets += response.items
                print("Updated tweets. count:", self.tweets.count)
                dispatch_async(dispatch_get_main_queue()) { [weak self] in
                    if response.items.count == 0 {
                        self?.canSearch = false
                        return
                    }
                    
                    self?.collectionView.reloadData()
                    let delay = 1.0 * Double(NSEC_PER_SEC)
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue(), {
                        self?.isLoading = false
                    })
                }
                
            case .failure(let error):
                print(error)
                Alert(title: "エラー！", message: "取得に失敗しました。").addOk().show(self)
                self.isLoading = false
            }
        }
    }
    
    private func selectTwitterAccount(completion: () -> ()) {
        
        let accountStore = ACAccountStore()
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { [weak self] granted, error in
            guard let `self` = self else { return }
            
            if let error = error {
                Alert(title: "エラー!", message: error.localizedDescription).addOk().show(self)
                return
            }
            
            if !granted {
                Alert(title: "エラー!", message: "Twitterアカウントの利用が許可されていません").addOk().show(self)
                return
            }
            
            let accounts = accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            if accounts.isEmpty {
                Alert(title: "エラー!", message: "設定アプリからTwitterアカウントを追加してください").addOk().show(self)
                return
            }
            
            let alert = Alert(title: "Twittrアカウントを選択してください", style: .ActionSheet)
            accounts.forEach { account in
                alert.addDefault(account.username) { [weak self] in
                    print("your select account is \(account)")
                    self?.twAccount = account
                    completion()
                }
            }
            alert.addCancel().show(self)
        }
    }

}


// MARK: - :UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        if tweets.count > indexPath.row {
            cell.tweet = tweets[indexPath.row]
        }
        return cell
    }
}


// MARK: - :UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if tweets.count - indexPath.row < 40 && 50..<1000 ~= tweets.count {
            let count = min(1000 - tweets.count, 100)
            let maxId = tweets.last!.statusId - 1
            sendSearchRequest(sinceId: maxId, count: count)
        }
    }
}


// MARK: - :UICollectionViewDelegateFlowLayout

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let cellWidth = view.frame.width - 8
        let textWidth = cellWidth - 16
        
        let attr = NSAttributedString(string: tweets[indexPath.row].text,
                                      attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        let size = CGSize(width: textWidth, height: 0)
        let rect = attr.boundingRectWithSize(size, options: [.UsesLineFragmentOrigin], context: nil)
        
        return CGSize(width: cellWidth, height: rect.height + 65)
    }
}
