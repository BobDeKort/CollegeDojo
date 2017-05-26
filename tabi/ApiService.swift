//
//  ApiService.swift
//  youtube
//
//  Created by Brian Voong on 6/30/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import FBSDKLoginKit
class ApiService: NSObject {

    static let sharedInstance = ApiService()
    
    var delegate: CurrentUserIsSetProtocol?
    
    // Base url for api usage
    let baseUrl = "https://tabi-backend.herokuapp.com/api/v1/"
    
    // Fetch events for home View

    func fetchEvents(_ completion: @escaping ([Event]) -> ()){
        // change to events
        if let user = CurrentUser.user {
            let url = baseUrl + "events?school_id=\(user.school_id)&user_id=\(user.id)"
            fetchEventsForUrlString(url, completion: completion)
        }
    }
    
    // Fetch favorite events for current user
    
    func fetchSavedEvents(_ completion: @escaping ([Event]) -> ()){
        if let user = CurrentUser.user {
            let url = baseUrl + "users/\(user.id)/favorites"
            fetchEventsForUrlString(url, completion: completion)
        }
    }
    
    func fetchFreeFoodEvents(_ completion: @escaping ([Event]) -> ()){
        if let user = CurrentUser.user {
            let url = baseUrl + "events?school_id=\(user.school_id)&user_id=\(user.id)"
            fetchEventsForUrlString(url, completion: completion)
        }
    }
    
    // searches database for search query
    
    func searchEvents(query: String, completion: @escaping ([Event]) -> ()){
        if let user = CurrentUser.user {
            let url = baseUrl + "events?search=\(query)&school_id=\(user.school_id)&user_id=\(user.id)"
            fetchEventsForUrlString(url, completion: completion)
        }
    }
    
    // MARK: Users, Login, Logout
    
    // Main login function
    func login(token: String, schoolId: Int, completion: @escaping (User)->()){
        
        let url = URL(string: baseUrl + "/users?token=\(token)&school_id=\(schoolId)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            
            if error != nil {
                print(error ?? "Error retrieving from url")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        if let unwrappedData = data, let jsonDictionaries = try JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [String: AnyObject] {
                            
                            let id = jsonDictionaries["id"] as! Int
                            let firstName = jsonDictionaries["first_name"] as! String
                            let lastName = jsonDictionaries["last_name"] as! String
                            let email = jsonDictionaries["email"] as! String?
                            let image = jsonDictionaries["image"] as! String
                            let schoolId = jsonDictionaries["school_id"] as! Int
                            let token = jsonDictionaries["oauth_token"] as! String
                            let uid = jsonDictionaries["uid"] as! String
                            
                            let user = User(id: id, lastName: lastName, firstName: firstName, email: email, image: image, schoolId: schoolId, token: token, uid: uid)
                            
                            var favorites: [Event]? = nil
                            if let events = jsonDictionaries["events"] as? [[String: AnyObject]] {
                                favorites = events.map({return Event(dictionary: $0)})
                            }
                            
                            self?.saveUserIdToUserDefaults(userId: user.id)
                            
                            CurrentUser.user = user
                            CurrentUser.favorites = favorites
                            
                            if let delegate = self?.delegate {
                                delegate.currentUserIsSet()
                            }
                            
                            DispatchQueue.main.async(execute: {
                                completion(user)
                            })
                        }
                        
                    } catch let jsonError {
                        print(jsonError)
                    }
                }
            }
        }) .resume()
    }

    
    // retrieves user that was logged in Last
    
    func retrieveCurrentUser(userId: Int, completionFavorites: @escaping ([Event]?) -> Void){
        let url = "https://tabi-backend.herokuapp.com/api/v1/" + "/users/\(userId)"
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            
            if error != nil {
                print(error ?? "Error retrieving from url")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        if let unwrappedData = data, let jsonDictionaries = try JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [String: AnyObject] {
                            
                            // Make user and assign to user singleton to
                            //                            print(unwrappedData)
                            let id = jsonDictionaries["id"] as! Int
                            let firstName = jsonDictionaries["first_name"] as! String
                            let lastName = jsonDictionaries["last_name"] as! String
                            let email = jsonDictionaries["email"] as! String?
                            let image = jsonDictionaries["image"] as! String
                            let schoolId = jsonDictionaries["school_id"] as! Int
                            //TODO:  change default value!!!!!
                            let token = jsonDictionaries["oauth_token"] as? String ?? ""
                            //TODO: change default value!!!
                            let uid = jsonDictionaries["uid"] as? String ?? ""
                            
                            let user = User(id: id, lastName: lastName, firstName: firstName, email: email, image: image, schoolId: schoolId, token: token, uid: uid)
                            
                            var favorites: [Event]? = nil
                            if let events = jsonDictionaries["events"] as? [[String: AnyObject]] {
                                favorites = events.map({return Event(dictionary: $0)})
                            }
                            
                            CurrentUser.user = user
                            CurrentUser.favorites = favorites
                            
                            completionFavorites(favorites)
                            
                            if let delegate = self?.delegate {
                                delegate.currentUserIsSet()
                            }
                        }
                        
                    } catch let jsonError {
                        print(jsonError)
                    }
                }
            }
        })
        task.resume()
    }
    
    // Saves UserId to Userdefaults for later usage
    
    func saveUserIdToUserDefaults(userId: Int){
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(userId, forKey: "UserId")
    }
    
    // Retrieves previously logged in userid from userDefaults
    
    func retrieveUserIdFromUserDefaults() -> Int?{
        let userDefaults = UserDefaults.standard
        if let userId = userDefaults.string(forKey: "UserId") {
            return Int(userId)
        } else {
            print("No user id in UserDefaults")
            return nil
        }
    }
    
    // retrieves last logged in user's id from user defaults and retrieves full user object from api
    
    func isLoggedIn(){
        let userId = ApiService.sharedInstance.retrieveUserIdFromUserDefaults()
        if let id = userId {
            ApiService.sharedInstance.retrieveCurrentUser(userId: id, completionFavorites: {(events) in })
        }
    }
    
    // Facebook Logout

    static func logout(){
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
    }
    
    // MARK: Events
    
    // Fetches events from api using given url and converts them into Event model
    
    func fetchEventsForUrlString(_ urlString: String, completion: @escaping ([Event]) -> ()) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url, completionHandler: {  (data, response, error) in
                
                if error != nil {
                    print(error ?? "Error retrieving from url")
                    return
                }
                
                do {
                    if let unwrappedData = data, let jsonDictionaries = try JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [[String: AnyObject]] {
                        
                        DispatchQueue.main.async(execute: {
                            completion(jsonDictionaries.map({return Event(dictionary: $0)}))
                        })
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }) .resume()
        }
    }
    
    func fetchSingleEvent(eventId: String, completion: @escaping (Event) -> Void){
        let url = "https://tabi-backend.herokuapp.com/api/v1/events/\(eventId)"
        
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url, completionHandler: {  (data, response, error) in
                
                if error != nil {
                    print(error ?? "Error retrieving from url")
                    return
                }
                
                do {
                    if let unwrappedData = data, let jsonDictionaries = try JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [String: AnyObject] {
                        
                        // Parse data
                        let event = Event(dictionary: jsonDictionaries)
                        
                        DispatchQueue.main.async(execute: {
                            completion(event)
                        })
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }) .resume()
        }
    }
    
    // Uses the current user id to like an event
    
    static func favoriteEvent(eventId: Int){
        
        if let user = CurrentUser.user {
                let url = "https://tabi-backend.herokuapp.com/api/v1/" + "user_event_favorites?event_id=\(eventId)&user_id=\(user.id)"
                
                var request = URLRequest(url: URL(string: url)!)
                request.httpMethod = "POST"
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("error: \(error)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("statusCode: \(httpStatus.statusCode)")
                        print("response: \(response)")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString: \(responseString)")
                }
                task.resume()
        }
        
    }
    
    // Uses the current user id to un like an event
    
    static func deleteFavoriteEvent(eventId: Int){
        if let user = CurrentUser.user {
            let url = "https://tabi-backend.herokuapp.com/api/v1/" + "user_event_favorites/0?event_id=\(eventId)&user_id=\(user.id)"
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "DELETE"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error: \(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode: \(httpStatus.statusCode)")
                    print("response: \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString: \(responseString)")
            }
            task.resume()
        }
    }
    
    func getSchools(completion: @escaping (([School]) -> Void)){
        let url = "https://tabi-backend.herokuapp.com/api/v1/schools"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if error != nil {
                print(error ?? "Error retrieving from url")
                return
            }
            
            do {
                if let unwrappedData = data, let jsonDictionaries = try JSONSerialization.jsonObject(with: unwrappedData, options: .mutableContainers) as? [[String: AnyObject]] {
                    
                    // Parse data
                    print(jsonDictionaries)
                    var schoolArray: [School] = []
                    
                    for i in jsonDictionaries {
                        
                        let name = i["name"] as? String
                        let lat = i["latitude"] as? Double
                        let lon = i["longitude"] as? Double
                        let id = i["id"] as? Int
                        
                        
                        let school = School(name: name!, lat: lat!, lon: lon!, id: id!)
                        schoolArray.append(school)

                    }
                    
                    DispatchQueue.main.async(execute: {
                        completion(schoolArray)
                    })
                    
                }
                
            } catch let jsonError {
                print(jsonError)
            }
        })
        task.resume()
    
    }
}

