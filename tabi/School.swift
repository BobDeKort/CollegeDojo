//
//  School.swift
//  Tabi
//
//  Created by Bob De Kort on 2/2/17.
//  Copyright © 2017 letsbuildthatapp. All rights reserved.
//

import Foundation

class School {
    let name: String
    let latitude: Double
    let longitude: Double
    let id: Int
    
    init(name: String, lat: Double, lon: Double, id: Int) {
        self.name = name
        self.latitude = lat
        self.longitude = lon
        self.id = id
    }
}
