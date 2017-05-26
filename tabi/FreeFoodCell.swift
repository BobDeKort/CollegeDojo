//
//  SavedCell.swift
//  tabi
//
//  Created by Bob De Kort on 12/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

class FreeFoodCell: HomeCell {
    
    override var events: [Event]? {
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func fetchEvents() {
        ApiService.sharedInstance.fetchFreeFoodEvents({ [unowned self] (events: [Event]) in
            
            var tempEvents: [Event] = []
            self.refreshControl.beginRefreshing()
            for event in events{
                if let isFreeFood = event.free_food {
                    if isFreeFood == 1 {
                        tempEvents.append(event)
                    }
                    
                }
            }
            self.events = tempEvents
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
            
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! EventCell
        
        
        let event = events?[indexPath.item]
        cell.event = event
        cell.likeButton.event = event
        cell.likeButton.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        
        return cell
    }
    
    override func likeButtonPressed(sender: LikeButton){
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
}
