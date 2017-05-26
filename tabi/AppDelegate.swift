//
//  AppDelegate.swift
//  youtube
//
//  Created by Brian Voong on 6/1/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var loadedEnoughToDeepLink : Bool = false
    var deepLink : RemoteNotificationDeepLink?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let layout = UICollectionViewFlowLayout()

        // does not work in simulator because of a bug, does work on actual device
        if (FBSDKAccessToken.current() != nil) {
            
            ApiService.sharedInstance.isLoggedIn()
            
            let statusBarBackgroundView = UIView()
            statusBarBackgroundView.backgroundColor = UIColor.productColor()
            
            window?.addSubview(statusBarBackgroundView)
            window?.addConstraintsWithFormat("H:|[v0]|", views: statusBarBackgroundView)
            window?.addConstraintsWithFormat("V:|[v0(20)]", views: statusBarBackgroundView)
            
            window?.rootViewController = UINavigationController(rootViewController: HomeController(collectionViewLayout: layout))
        } else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController: LoginViewController = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! LoginViewController
            
            
            window?.rootViewController = UINavigationController(rootViewController: loginViewController)
        }
        
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = UIColor.productColor()
        
        // get rid of black bar underneath navbar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        
        application.statusBarStyle = .lightContent
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.host == nil
        {
            return true;
        } else if url.scheme == "fb368511106816040" {
            
            let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            
            return handled
        }
        
        let urlString = url.absoluteString
        let queryArray = urlString.components(separatedBy: "/")
        let query = queryArray[2]
        
        // Check if article
        if query.range(of: "events") != nil
        {
            let data = urlString.components(separatedBy: "/")
            if data.count >= 3
            {
                let parameter = data[3]
                let userInfo = [RemoteNotificationDeepLinkAppSectionKey : parameter ]
                self.applicationHandleRemoteNotification(app, didReceiveRemoteNotification: userInfo)
            }
        }
        
        return true

    }
    
    func applicationHandleRemoteNotification(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
        if application.applicationState == UIApplicationState.background || application.applicationState == UIApplicationState.inactive
        {
            let canDoNow = loadedEnoughToDeepLink
            
            self.deepLink = RemoteNotificationDeepLink.create(userInfo)
            
            if canDoNow
            {
                _ = self.triggerDeepLinkIfPresent()
            }
        }
    }
    
    
    func triggerDeepLinkIfPresent() -> Bool
    {
        self.loadedEnoughToDeepLink = true
        let ret = (self.deepLink?.trigger() != nil)
        self.deepLink = nil
        return ret
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
}

