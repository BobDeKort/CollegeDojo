//
//  User.swift
//  Tabi
//
//  Created by Kojin on 12/12/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import Foundation

protocol CurrentUserIsSetProtocol {
    func currentUserIsSet()
}

class User: NSObject {
    
    var id: Int
    var lastName: String
    var firstName: String
    var email: String?
    var image: String
    var school_id: Int
    var oauthToken: String
    var uid: String
    
    init(id: Int, lastName: String, firstName: String, email: String?, image: String, schoolId: Int, token: String, uid: String) {
        self.id = id
        self.lastName = lastName
        self.firstName = firstName
        self.email = email
        self.image = image
        self.school_id = schoolId
        self.oauthToken = token
        self.uid = uid
    }
    
}

struct CurrentUser {
    
    static var user: User?
    static var favorites: [Event]?
}
