//
//  Model.swift
//  Weather
//
//  Created by jassak on 30/11/2020.
//  Copyright © 2020 jassak1. All rights reserved.
//

import Foundation

struct FHierarchy:Codable {
    var current:SHierarchy
    var daily:[Daily]
}
struct SHierarchy:Codable {
    var temp:Double
    var feels_like:Double
    var weather:[THierarchy]
}
struct THierarchy:Codable {
    var description:String
    var icon:String
}
struct Daily:Codable,Identifiable {
    var id:UUID{
        UUID()
    }
    var dt:Date
    var temp:DailyTemp
    var pop:Double
    var weather:[THierarchy]
}
struct DailyTemp:Codable {
    var day:Double
}

struct Favorites:Codable, Identifiable {
    var id=UUID()
    var name:String
    var latitude:Double
    var longitude:Double
}
