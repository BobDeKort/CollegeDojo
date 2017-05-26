//
//  SavedCell.swift
//  tabi
//
//  Created by Bob De Kort on 12/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

class SavedCell: HomeCell {
    
    override func fetchEvents() {
        self.refreshControl.beginRefreshing()
        
        if let user = CurrentUser.user {
            
                // also loads saved events from user
            ApiService.sharedInstance.retrieveCurrentUser(userId: user.id, completionFavorites: { [unowned self] (events) in
                if let events = events{
                    for event in events{
                        event.liked = true
                    }
                    self.events = events
                }
                self.collectionView.reloadData()
            })
        }
        
        self.collectionView.reloadData()
        self.refreshControl.endRefreshing()
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
