//
//  WeatherView.swift
//  Weather
//
//  Created by jassak on 01/12/2020.
//  Copyright © 2020 jassak1. All rights reserved.
//

import SwiftUI

struct WeatherView: View {
    @Environment(\.presentationMode) var hide
    var equalname:String
    @ObservedObject var weatherFetch:WeatherFetch
    @ObservedObject var weatherData:WeatherData
    
    var body: some View {
        NavigationView {
            VStack{
                if (!weatherFetch.results.isEmpty){
                    List{
                        VStack(alignment:.leading) {
                            Text("\(weatherData.getDate())").foregroundColor(Color("Gray"))
                            Text(equalname)
                        }.padding().listRowBackground(Color.black)
                        HStack(){
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(weatherFetch.weatherResponse("temperature")) °C").font(.system(size: 64)).fontWeight(.black)
                                Text(weatherFetch.weatherResponse("description")).font(.system(size: 32))
                                Text("feelTemp \(weatherFetch.weatherResponse("feels_like"))")
                                    .font(.system(size: 16)).foregroundColor(Color("Gray"))
                            }
                            .padding()
                            Spacer()
                        }.listRowBackground(Color.black)
                        ForEach(weatherFetch.results[0].daily){received in
                            VStack(alignment:.leading) {
                                HStack(spacing:10){
                                    Text("\(weatherFetch.getDate(received.dt))").frame(maxWidth:.infinity,alignment: .leading)
                                    Spacer()
                                    HStack {
                                        Image(received.weather[0].icon).resizable().frame(width:30,height:30)
                                        Text("\(received.pop*100,specifier: "%g") %")
                                    }.frame(maxWidth:.infinity,alignment: .center)
                                    Spacer()
                                    Text("\(round(received.temp.day),specifier: "%g") °C").frame(maxWidth:.infinity,alignment: .trailing)
                                }.padding()
                            }
                        }.font(.system(size: 14)).listRowBackground(Color.black)
                        HStack{
                            if weatherData.stored.contains(where:{$0.name == equalname}){
                                Button(action:{
                                    let a=weatherData.stored.firstIndex(where: {$0.name==equalname}) ?? 2
                                    weatherData.stored.remove(at: a)
                                    weatherData.save(file: weatherData.stored)
                                    self.hide.wrappedValue.dismiss()
                                }){
                                    Text("deleteFav").foregroundColor(.red)
                                }.padding()
                            }
                            else{
                                Button(action:{
                                    weatherData.getCoordinates(withSave: true, city: equalname){a in}
                                }){
                                    Text("addFav").foregroundColor(Color("Purple"))
                                }.padding()
                            }
                            Spacer()
                        }.buttonStyle(BorderlessButtonStyle())
                        .listRowBackground(Color.black)
                    }.listStyle(GroupedListStyle())
                    
                }
            }
            .navigationBarHidden(true)
        }
        .navigationBarTitle(Text("\(equalname)"),displayMode: .inline)
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(equalname:"R", weatherFetch: WeatherFetch(),weatherData: WeatherData())
    }
}
