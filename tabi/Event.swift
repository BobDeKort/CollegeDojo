//
//  Event.swift
//  youtube
//
//  Created by Bob De Kort on 12/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import Foundation

class SafeJsonObject: NSObject {
    
    
    override func setValue(_ value: Any?, forKey key: String) {
        let uppercasedFirstCharacter = String(key.characters.first!).uppercased()
        
        let range = NSMakeRange(0, 1)
        let selectorString = NSString(string: key).replacingCharacters(in: range, with: uppercasedFirstCharacter)
        
        let selector = NSSelectorFromString("set\(selectorString):")
        let responds = self.responds(to: selector)
        
        if !responds {
            return
        }
        
        super.setValue(value, forKey: key)
    }
    
}

class Event: SafeJsonObject {
    let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    var id: NSNumber?
    var title: String?
    var start_time: Date?
    var end_time: Date?
    var price: NSNumber?
    var location: String?
    var location_address: String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var event_description: String?
    var created_at: Date?
    var updated_at: Date?
    var user_id: NSNumber?
    var url: String?
    var image: String?
    var school_id: Int?
    var liked: NSNumber?
    var free_food: NSNumber?
    
    var ib_id: String?
    var fb_id: String?
    
    override func setValue(_ value: Any?, forKey key: String){
        let datesArray = ["start_time", "end_time", "created_at", "updated_at"]
        if datesArray.contains(key) {
            if value != nil {
                let date = dateFromString(date: value as! String, format: dateFormat) as Date
                switch key {
                case "start_time":
                    self.start_time = date
                case "end_time":
                    self.end_time = date
                case "created_at":
                    self.created_at = date
                case "updated_at":
                    self.updated_at = date
                default: break
                }
            }
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        setValuesForKeys(dictionary)
    }
    
    init(id: NSNumber, title: String, start_time: Date, end_time: Date, price: NSNumber, location: String, lat: NSNumber, lon: NSNumber, description: String, created_at: Date, updated_at: Date, user_id: NSNumber, url: String, image: String, school_id: Int, liked: NSNumber, freeFood: NSNumber) {
        self.id = id
        self.title = title
        self.start_time = start_time
        self.end_time = end_time
        self.price = price
        self.location = location
        self.latitude = lat
        self.longitude = lon
        self.event_description = description
        self.created_at = created_at
        self.updated_at = updated_at
        self.user_id = user_id
        self.url = url
        self.image = image
        self.school_id = school_id
        self.liked = liked
        self.free_food = freeFood
    }
}

public func dateFromString(date: String, format: String) -> Date {
    
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = format
    let newDate = dateFormatter.date(from: date)! as Date
    
    return newDate
}
