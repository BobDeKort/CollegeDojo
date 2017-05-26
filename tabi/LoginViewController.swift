//
//  LoginViewController.swift
//  Tabi
//
//  Created by Kojin on 12/12/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var cellId = "cellId"
    var school: School? {
        didSet{
            subView.schoolId = school?.id
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.backgroundColor = UIColor.lightGray
        return cv
    }()
    
    lazy var subView: LoginSubView = {
        let view = LoginSubView()
        view.navigationController = self.navigationController
        view.parentView = self
        view.backgroundColor = .white
        return view
    }()
    
    var myActivityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        view.hidesWhenStopped = true
        return view
    }()
    
    
    let pages: [String] = {
        let page1 = "page1"
        let page2 = "page2"
        let page3 = "page3"
        
        return [page1, page2, page3]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationItem.backBarButtonItem?.tintColor = .white
        
        view.addSubview(collectionView)
        view.addSubview(subView)
        view.addSubview(myActivityIndicator)
        
        myActivityIndicator.frame = CGRect(x: view.center.x - 25, y: view.center.y, width: 50, height: 50)
        
        
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: subView.topAnchor, right: view.rightAnchor)
        
        subView.anchorToTop(collectionView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        collectionView.register(LoginCollectionViewCell.self, forCellWithReuseIdentifier: cellId)

        showSchoolPicker()
    }
    
    func showActivityMonitor(){
        myActivityIndicator.isHidden = false
        myActivityIndicator.startAnimating()
    }
    
    func hideActivityMonitor(){
        myActivityIndicator.stopAnimating()
        myActivityIndicator.isHidden = true
    }
    
    func showSchoolPicker(){
        // Show School Picker View
        
        let schoolPicker = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "schoolPicker") as! SchoolPickerViewController
        self.addChildViewController(schoolPicker)
        schoolPicker.view.frame = self.view.frame
        self.view.addSubview(schoolPicker.view)
        schoolPicker.didMove(toParentViewController: self)
    }

    //PageControl Setup
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        subView.pageControl.currentPage = pageNumber
    }
    
    
    // CollectionView Setup
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LoginCollectionViewCell
        
        cell.pageImage = pages[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    // Facebook Login
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
