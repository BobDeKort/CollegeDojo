//
//  RemoteNotificationDeepLink.swift
//  DeepLink
//
//  Created by Brian Coleman on 2015-07-12.
//  Copyright (c) 2015 Brian Coleman. All rights reserved.
//

import UIKit

let RemoteNotificationDeepLinkAppSectionKey : String = "events"

class RemoteNotificationDeepLink: NSObject {
   
    var event : String = ""
    
    class func create(_ userInfo : [AnyHashable: Any]) -> RemoteNotificationDeepLink?
    {
        let info = userInfo as NSDictionary
        
        let articleID = info.object(forKey: RemoteNotificationDeepLinkAppSectionKey) as! String
        
        var ret : RemoteNotificationDeepLink? = nil
        if !articleID.isEmpty
        {
            ret = RemoteNotificationDeepLinkArticle(articleStr: articleID)
        }
        return ret
    }
    
    fileprivate override init()
    {
        self.event = ""
        super.init()
    }
    
    fileprivate init(articleStr: String)
    {
        self.event = articleStr
        super.init()
    }
    
    final func trigger()
    {
        DispatchQueue.main.async
            {
                
                self.triggerImp()
                    { (passedData) in
                        // do nothing
                }
        }
    }
    
    fileprivate func triggerImp(_ completion: ((AnyObject?)->(Void)))
    {
        
        completion(nil)
    }
}

class RemoteNotificationDeepLinkArticle : RemoteNotificationDeepLink
{
    var eventId : String!
    
    override init(articleStr: String)
    {
        self.eventId = articleStr
        super.init(articleStr: articleStr)
    }
    
    fileprivate override func triggerImp(_ completion: ((AnyObject?)->(Void)))
    {
        super.triggerImp()
            { (passedData) in
                
                ApiService.sharedInstance.fetchSingleEvent(eventId: self.eventId, completion: { (event) in
          
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    let navigationController = appDelegate.window?.rootViewController as! UINavigationController
                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                        vc.event = event

                    navigationController.pushViewController(vc, animated: true)
                    
                })
                
                completion(nil)
        }
    }
    
}
