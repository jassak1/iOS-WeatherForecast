//
//  SearchView.swift
//  Weather
//
//  Created by jassak on 01/12/2020.
//  Copyright © 2020 jassak1. All rights reserved.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @ObservedObject var weatherFetch:WeatherFetch
    @ObservedObject var weatherData:WeatherData
    @ObservedObject var locationSearchService=LocationSearchService()
    @ObservedObject var weatData=WeatherData()
    @State var showKeyboard=false
    var body: some View {
        NavigationView {
            VStack(alignment:.leading) {
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)).frame(height:30)
                            .overlay(HStack {
                                Image(systemName: "magnifyingglass").foregroundColor(Color("Purple")).padding(.leading,10)
                                TextField("Search",text:$locationSearchService.searchQuery, onEditingChanged:{_ in
                                            weatherFetch.showKeyboard=true
                                            showKeyboard = true})
                                if(!locationSearchService.searchQuery.isEmpty){
                                    Button(action:{
                                        locationSearchService.searchQuery=""
                                    }){
                                        Image(systemName: "xmark.circle.fill").padding(.trailing,5).foregroundColor(Color("Gray"))
                                    }
                                }
                            })
                            .padding(.vertical)
                        if showKeyboard{
                            Button(action:{
                                UIApplication.shared.endEditing(true)
                                weatherFetch.showKeyboard=false
                                showKeyboard = false
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }){
                                Text("Cancel")
                            }}
                    }.padding(.horizontal)
                    .padding(.top)
                    if(!locationSearchService.searchQuery.isEmpty){
                        List{
                            ForEach(locationSearchService.completions,id:\.self){completion in
                                VStack(alignment:.leading) {
                                    NavigationLink(
                                        destination:
                                            WeatherView(equalname:completion.title,  weatherFetch:weatherFetch,weatherData: weatherData).onAppear(){
                                                weatData.getCoordinates(withSave: false, city:completion.title){a in
                                                    weatherFetch.loadData(latitude: a.latitude, longitude: a.longitude)
                                                }
                                            },
                                        label: {
                                            Text(completion.title)
                                        }).id(completion.title)
                                }
                            }.listRowBackground(Color.black)
                        }.listStyle(GroupedListStyle())
                    }
                    
                }
                Spacer()
            }.navigationBarTitle(Text("searchTab"))
            .navigationBarHidden(showKeyboard)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(weatherFetch: WeatherFetch(), weatherData: WeatherData())
    }
}


