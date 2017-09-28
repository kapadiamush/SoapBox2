//
//  TwitterClient.swift
//  SoapBox
//
//  Created by Mushaheed Kapadia on 9/28/17.
//  Copyright © 2017 Mushaheed Kapadia. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {

    private static let singleton: TwitterClient! = TwitterClient(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "4xNvYjA8PFwogWxMDZgOPIMeA", consumerSecret: "ynYmrqAumMFs6eg2Yk1K4Hu6rHa17iYuJs8IgHENKAxH0OAOUC")
    
    var @escaping loginSuccess: (() -> Void)?
    var @escaping loginFailure: ((Error?) -> Void)?
    
    class func getInstance() -> TwitterClient {
        return singleton
    }
    
    func login(success:  (() -> Void), failure: @escaping ((Error?) -> Void) ) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterDemo://oauth")!, scope: nil, success: { (requestToken: BDBOAuth1Credential!) in
            let urlString: String = "https://api.twitter.com/oauth/authenticate?oauth_token=\(requestToken.token!)"
            let url: URL = URL(string: urlString)!
            print(urlString)
            UIApplication.shared.open(url, options: [String : Any](), completionHandler: { (success) in
                // do nothing right now
            })
        }, failure: {(error: Error?) -> Void in
            loginFailure!(error)
        })
    }
    
    func currentAccount(success: @escaping ((User) -> Void), failure: @escaping ((Error?) -> Void)) {
        // get current user
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil,  success: { (task, response) in
            // do nothing
            let userDict = response as! NSDictionary
            let user = User(userDict: userDict)
            success(user)
        }, failure: { (taks, error) in
            failure(error)
        })
    }
    
    func homeTimeline(success: @escaping (([Tweet]) -> Void), failure: @escaping ((Error?) -> Void)) {
        // get tweets
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil,  success: { (task, response) in
            let tweetDicts = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(tweetDicts: tweetDicts)
            success(tweets)
        }, failure: { (taks, error) in
            failure(error)
        })
    }
}