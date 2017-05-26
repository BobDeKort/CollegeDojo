//
//  Config.swift
//  Tabi
//
//  Created by Kojin on 12/18/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//


import UIKit

class Config{
    static var wholeDict: [String: AnyObject]!
    static var apiCalls: [String:AnyObject]!
    static var config: [String:AnyObject]!
}

//creation functions
extension Config{
    static func loadConfig(){
        guard let conf = Config.JSONFromFileName(fileName: "Config") else {
            print("ERROR: Coult not create config from JSON")
            return
        }
        Config.wholeDict = conf
        Config.config = Config.wholeDict["config"] as? [String:AnyObject]
        Config.apiCalls = Config.config["apiCalls"] as? [String:AnyObject]
    }
    
    static func JSONFromFileName(fileName: String) -> [String:AnyObject]?{
        if let pathString = Bundle.main.path(forResource: fileName.components(separatedBy: ".")[0], ofType: "json"){
            let path = URL(fileURLWithPath: pathString)
            do{
                let jsonData = try Data(contentsOf: path, options: .alwaysMapped)
                //                    let js = JSON(data: jsonData)
                if let jsonResult: [String:AnyObject] = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]{
                    return jsonResult
                }
                
            }catch{
                print(error)
                fatalError()
            }
            
            
            
        }
        return nil
    }
}
