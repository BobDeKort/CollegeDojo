//
//  LoginSubView.swift
//  onBoarding
//
//  Created by Bob De Kort on 12/18/16.
//  Copyright © 2016 Bob De Kort. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginSubView: UIView, FBSDKLoginButtonDelegate{
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1)
        pc.numberOfPages = 3
        return pc
    }()
    
    var schoolId: Int?
    
    var navigationController: UINavigationController?
    
    var parentView: LoginViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_events"]
        loginButton.publishPermissions = ["publish_actions"]
        addSubview(loginButton)
        

        loginButton.frame = CGRect(x: 16, y: 50, width: self.frame.width - 200, height: 50)
        
        loginButton.delegate = self
        
        addSubview(pageControl)
        
        
        _ = pageControl.anchor(topAnchor, left: leftAnchor, bottom: loginButton.topAnchor, right: rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        
        _ = loginButton.anchor(pageControl.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            return
        }
        parentView?.showActivityMonitor()
        
        let accessToken = FBSDKAccessToken.current()
        // sign in the user
        guard let accessTokenString = accessToken?.tokenString else { return }
        if let schoolId = schoolId {
            ApiService.sharedInstance.login(token: accessTokenString, schoolId: schoolId, completion: { (user) in
                
            })
        }
        self.parentView?.hideActivityMonitor()
        let layout = UICollectionViewFlowLayout()
        let vc = HomeController(collectionViewLayout: layout)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
}
