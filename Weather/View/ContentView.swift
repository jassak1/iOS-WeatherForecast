//
//  ContentView.swift
//  Weather
//
//  Created by jassak on 30/11/2020.
//  Copyright © 2020 jassak1. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var favorites = false
    @State var search = false
    
    @ObservedObject var mapType=MapData()
    @ObservedObject var weatherFetch=WeatherFetch()
    @ObservedObject var weatherData=WeatherData()
    @State var tabs=0
    
    
    var body: some View {
        GeometryReader{geo in
            ZStack(alignment:.bottomLeading) {
                TabView(selection:$tabs){
                    MapView(mapType: mapType, weatherFetch: weatherFetch, weatherData: weatherData)
                        .tabItem {
                            Image(systemName: "map")
                            Text("mapTab")
                        }.tag(0)
                    
                    SearchView(weatherFetch: weatherFetch, weatherData: weatherData)
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("searchTab")
                        }.tag(1)
                    
                    FavoritesView(weatherFetch: weatherFetch, weatherData: weatherData)
                        .tabItem {
                            Image(systemName: "star")
                            Text("favoritesTab")
                        }.tag(2)
                    
                }.accentColor(Color("Purple"))
                if (!weatherFetch.showKeyboard){
                    BadgeView(weatherData: weatherData)
                        .offset(x: geo.size.width*5.1/6, y: -30)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BadgeView: View {
    @ObservedObject var weatherData:WeatherData
    var body: some View {
        
        if(!weatherData.stored.isEmpty){
            Image(systemName: "circle.fill").foregroundColor(.red)
                .overlay(Text("\(weatherData.stored.count)").minimumScaleFactor(0.1))
        }
    }
}
