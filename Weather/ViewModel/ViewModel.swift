//
//  ViewModel.swift
//  Weather
//
//  Created by jassak on 30/11/2020.
//  Copyright © 2020 jassak1. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class WeatherData: ObservableObject {
    @Published var stored=[Favorites]()
    
    func save(file:[Favorites]){
        guard let encode = try? JSONEncoder().encode(file) else {
            return
        }
        UserDefaults.standard.set(encode,forKey: "savedData")
    }
    
    func getCoordinates(withSave:Bool,city:String,completion: @escaping (CLLocationCoordinate2D) -> Void){
        let searchQuest=MKLocalSearch.Request()
        searchQuest.naturalLanguageQuery=city
        let search=MKLocalSearch(request: searchQuest)
        search.start{response,error in
            guard let response = response else {
                return
            }
            let b=(response.mapItems[0].placemark.coordinate)
            self.stored.append(Favorites(name: city, latitude: b.latitude, longitude: b.longitude))
            if withSave{
                self.save(file: self.stored)
            }
            completion(b)
        }
    }
    
    func getDate() -> String {
        let formatter=DateFormatter()
        formatter.dateStyle = .long
        return (formatter.string(from: Date()))
        
    }
    
    init() {
        guard let saved = UserDefaults.standard.data(forKey: "savedData") else {
            return
        }
        guard let decode = try? JSONDecoder().decode([Favorites].self, from: saved) else {
            return
        }
        stored=decode
    }
    
}

class MapData:NSObject, ObservableObject {
    
    var fetchData=WeatherFetch()
    @Published var reverseLatitude=Double(){
        didSet{
            currentLatitude=reverseLatitude
            currentLongitude=reverseLongitude
        }
    }
    @Published var reverseLongitude=Double()
    @Published var geoName=String()
    @Published var sheetActive=false{
        didSet{
            fetchData.loadData(latitude: reverseLatitude, longitude: reverseLongitude)
        }
    }
    @Published var mapType:Int=0
    @Published var currentLatitude:Double=48.736277{
        didSet{
            self.locationManager.stopUpdatingLocation()
        }
    }
    @Published var currentLongitude:Double=19.146192
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
    }
}

extension MapData: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLatitude = location.coordinate.latitude
        currentLongitude = location.coordinate.longitude
    }
}

class LocationSearchService: NSObject,ObservableObject,MKLocalSearchCompleterDelegate {
    let completer: MKLocalSearchCompleter = MKLocalSearchCompleter()
    @Published var searchQuery = String(){
        didSet{
            searchWord(completion: searchQuery)
        }
    }
    @Published var completions: [MKLocalSearchCompletion] = []
    
    func searchWord(completion:String) {
        completer.delegate = self
        completer.resultTypes = .address
        completer.queryFragment = completion
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.completions=completer.results
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
}

class WeatherFetch:ObservableObject {
    @Published var showKeyboard=false
    @Published var results=[FHierarchy]()
    func loadData(latitude:Double,longitude:Double) {
        showKeyboard=false
        var region="en"
        if(Locale.current.languageCode == "sk"){
            region="sk"
        }else{
            region="en"
        }
        guard let address = URL(string:
                                    "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&lang=\(region)&appid=YOUR_API_KEY_GOES_HERE") else {
            return
        }
        let request = URLRequest(url: address)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let downloaded = data else {
                return
            }
            let decoder=JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            guard let decodedResponse = try? decoder.decode(FHierarchy.self, from: downloaded) else{
                return
            }
            DispatchQueue.main.async {
                self.results = [decodedResponse]
            }
        }.resume()
    }
    
    func weatherResponse(_ keyword:String) -> String{
        if !results.isEmpty {
            switch keyword {
            case "description":
                return results[0].current.weather[0].description
            case "temperature":
                return String(format: "%g",round(results[0].current.temp))
            case "feels_like":
                return String(format: "%g",round(results[0].current.feels_like))
            default:
                return ""
            }
        }
        return ""
    }
    
    func getDate(_ date:Date) -> String {
        let formatter=DateFormatter()
        formatter.dateFormat="EEEE"
        return (formatter.string(from: date))
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}
