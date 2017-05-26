//
//  SearchViewController.swift
//  Tabi
//
//  Created by Bob De Kort on 1/9/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate {
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect.zero)
    
    var collectionView: UICollectionView!
    
    var events: [Event]? {
        didSet{
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        
        
        
        searchBar.delegate = self
        setupNavigationBar()
        setupCollectionView()
    }
    
    func dismissKeyboard() {
        self.searchBar.endEditing(true)
    }

    
    func setupCollectionView(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EventCell.self, forCellWithReuseIdentifier: "searchCell")
        collectionView.backgroundColor = .white
        self.view.addSubview(collectionView)
    }
    
    func setupNavigationBar(){
        
        // add backbutton
        let imageView = UIImageView(image: UIImage(named: "backButton"))
        imageView.contentMode = .right
        let arrowView = UIBarButtonItem(customView: imageView)
        
        
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(SearchViewController.goBack))
        backButton.tintColor = .white

        navigationItem.setLeftBarButtonItems([arrowView, backButton], animated: true)
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        // add TextField
        searchBar.placeholder = "Search"
        searchBar.sizeToFit()
        searchBar.frame.size.width = self.view.frame.size.width - (self.view.frame.size.width / 3)
        
        let searchField = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = searchField
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text {
            events = nil
            ApiService.sharedInstance.searchEvents(query: query, completion: { [unowned self] (events: [Event]) in
                
                self.events = events
                self.collectionView.reloadData()
                
            })
            collectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        goBack()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let events = events {
            collectionView.backgroundView = nil
            return events.count
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
            noDataLabel.text = "Sorry! There were no matches found"
            noDataLabel.textColor = UIColor.lightGray
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 2
            collectionView.backgroundView = noDataLabel
            return 0
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! EventCell
        
        
        let event = events?[indexPath.item]
        cell.event = event
        cell.likeButton.event = event
        cell.likeButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.event = events?[indexPath.item]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (view.frame.width - 16 - 16) * 9 / 16
        return CGSize(width: view.frame.width, height: height + 16 + 88)
    }
    
    func likeButtonPressed(sender: LikeButton){
        if let event = sender.event {
            if event.liked == true {
                if let eventId = sender.event?.id {
                    ApiService.deleteFavoriteEvent(eventId: Int(eventId))
                }
                
                event.liked = false
                sender.isSelected = false
                sender.reloadInputViews()
            } else {
                
                if let eventId = event.id {
                    ApiService.favoriteEvent(eventId: (Int(eventId)))
                }
                event.liked = true
                sender.isSelected = true
                sender.reloadInputViews()
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func goBack(){
         _ = navigationController?.popViewController(animated: true)
    }
}
