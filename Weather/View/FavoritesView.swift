//
//  FavoritesView.swift
//  Weather
//
//  Created by jassak on 30/11/2020.
//  Copyright © 2020 jassak1. All rights reserved.
//

import SwiftUI
import MapKit

struct FavoritesView: View {
    @State var eqname=String()
    @State var sheetPresent=false
    
    @ObservedObject var weatherFetch:WeatherFetch
    @ObservedObject var weatherData:WeatherData
    var body: some View {
        NavigationView{
            GeometryReader{geo in
                ScrollView(.vertical) {
                    VStack(alignment:.leading){                    
                        if (!weatherData.stored.isEmpty)
                        {
                            ForEach(0..<weatherData.stored.count/2){first in
                                HStack {
                                    ForEach(0..<2){second in
                                        GridView(latitude: weatherData.stored[first*2+second].latitude, longitude:weatherData.stored[first*2+second].longitude,headline:weatherData.stored[first*2+second].name,geoSize: geo).onTapGesture{
                                            eqname=weatherData.stored[first*2+second].name
                                            weatherFetch.loadData(latitude: weatherData.stored[first*2+second].latitude, longitude: weatherData.stored[first*2+second].longitude)
                                            sheetPresent=true}
                                    }
                                }
                            }.id(weatherData.stored.count)
                            if (weatherData.stored.count%2 != 0){
                                GridView(latitude: weatherData.stored.last?.latitude ?? 30.0, longitude:weatherData.stored.last?.longitude ?? 40.0, headline: weatherData.stored.last?.name ?? "NA", geoSize: geo).onTapGesture{
                                    eqname=weatherData.stored.last?.name ?? "NA"
                                    weatherFetch.loadData(latitude: weatherData.stored.last?.latitude ?? 30.0, longitude: weatherData.stored.last?.longitude ?? 40.0)
                                    sheetPresent=true}
                            }
                        }
                    }.sheet(isPresented: $sheetPresent){
                        WeatherView(equalname:eqname, weatherFetch: weatherFetch, weatherData: weatherData)
                    }
                }
            }.padding()
            .navigationBarTitle(Text("favoritesTab"))
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(weatherFetch: WeatherFetch(), weatherData: WeatherData())
    }
}

struct GridView: View {
    var latitude:Double
    var longitude:Double
    var headline:String
    var geoSize:GeometryProxy
    var body: some View {
        ShowMap(spanDelta:0.3, Latitude: latitude, Longitude: longitude, mapType: MapData()).frame(width: geoSize.size.width/2, height: geoSize.size.width/2).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).trim(from: 0.05, to: 0.45)).foregroundColor(Color("Gray")).overlay(VStack(alignment:.leading){
                Text(headline)
            }.padding(5),alignment: .bottomLeading)
    }
}
