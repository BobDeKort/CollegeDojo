//
//  HomeCell.swift
//  tabi
//
//  Created by Bob De Kort on 12/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

class HomeCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CurrentUserIsSetProtocol {

    lazy var activityIndicator = UIActivityIndicatorView()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    var events: [Event]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // Custom refresh control variables
    
    lazy var refreshControl = UIRefreshControl()
    var customView: UIView!
    var labelsArray: Array<UILabel> = []
    var isAnimating = false
    var currentColorIndex = 0
    var currentLabelIndex = 0
    
    // Collection view cell ID
    
    let cellId = "cellId"
    
    // "View Did Load"
    
    override func setupViews() {
        super.setupViews()
        backgroundColor = .white
        
        ApiService.sharedInstance.delegate = self
        
        fetchEvents()
        setupActivityIndicator()
        setUpRefreshControl()
        
        collectionView.alwaysBounceVertical = true
        
        
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)

        collectionView.register(EventCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func fetchEvents(){
        activityIndicator.startAnimating()
        ApiService.sharedInstance.fetchEvents({ [unowned self] (events: [Event]) in
            
            self.refreshControl.beginRefreshing()
            
            self.events = events
            self.collectionView.reloadData()
            
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
            
        })
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
    
    func setUpRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(self.fetchEvents), for: UIControlEvents.valueChanged)
        collectionView.addSubview(refreshControl)
        
        loadCustomRefreshContents()
    }
    
    func loadCustomRefreshContents() {
        let refreshContents = Bundle.main.loadNibNamed("RefreshContents", owner: self, options: nil)
        
        customView = refreshContents?[0] as! UIView
        customView.frame = refreshControl.bounds
        
        for i in 0 ..< customView.subviews.count {
            labelsArray.append(customView.viewWithTag(i + 1) as! UILabel)
        }
        
        refreshControl.addSubview(customView)
    }
    
    func setupActivityIndicator(){
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activityIndicator.center = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addSubview(activityIndicator)
    }
    
    func currentUserIsSet() {
        fetchEvents()
    }
    
    // MARK: CollectionView Cycle
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let events = events {
            if events.count == 0 {
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
                noDataLabel.text = "Sorry! No data available! \n Try again later!"
                noDataLabel.textColor = UIColor.lightGray
                noDataLabel.textAlignment = .center
                noDataLabel.numberOfLines = 2
                collectionView.backgroundView = noDataLabel
                return 0
            } else {
                collectionView.backgroundView = nil
                return events.count
            }
        } else {
            fetchEvents()
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! EventCell
        
        
        let event = events?[indexPath.item]
        cell.event = event
        cell.likeButton.event = event
        cell.likeButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (frame.width - 16 - 16) * 9 / 16
        return CGSize(width: frame.width, height: height + 16 + 88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        vc.event = events?[indexPath.item]
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // MARK: Animations
    
    func animateRefreshStep1() {
        isAnimating = true
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.labelsArray[self.currentLabelIndex].transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4))
            self.labelsArray[self.currentLabelIndex].textColor = self.getNextColor()
            
        }, completion: { (finished) -> Void in
            
            UIView.animate(withDuration: 0.05, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.labelsArray[self.currentLabelIndex].transform = .identity
                self.labelsArray[self.currentLabelIndex].textColor = UIColor.black
                
            }, completion: { (finished) -> Void in
                self.currentLabelIndex += 1
                
                if self.currentLabelIndex < self.labelsArray.count {
                    self.animateRefreshStep1()
                }
                else {
                    self.animateRefreshStep2()
                }
            })
        })
    }
    
    func animateRefreshStep2() {
        UIView.animate(withDuration: 0.35, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.labelsArray[0].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[1].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[2].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.labelsArray[3].transform = CGAffineTransform(scaleX: 1.5, y: 1.5)

            
        }, completion: { (finished) -> Void in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.labelsArray[0].transform = .identity
                self.labelsArray[1].transform = .identity
                self.labelsArray[2].transform = .identity
                self.labelsArray[3].transform = .identity

                
            }, completion: { (finished) -> Void in
                if self.refreshControl.isRefreshing {
                    self.currentLabelIndex = 0
                    self.animateRefreshStep1()
                }
                else {
                    self.isAnimating = false
                    self.currentLabelIndex = 0
                    for i in 0 ..< self.labelsArray.count {
                        self.labelsArray[i].textColor = UIColor.black
                        self.labelsArray[i].transform = .identity
                    }
                }
            })
        })
    }
    
    func getNextColor() -> UIColor {
        var colorsArray: Array<UIColor> = [UIColor.magenta, UIColor.brown, UIColor.yellow, UIColor.red, UIColor.green, UIColor.blue, UIColor.orange]
        
        if currentColorIndex == colorsArray.count {
            currentColorIndex = 0
        }
        
        let returnColor = colorsArray[currentColorIndex]
        currentColorIndex += 1
        
        return returnColor
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !isAnimating {
            animateRefreshStep1()
        }
    }
}
