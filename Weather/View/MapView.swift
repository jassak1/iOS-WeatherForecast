//
//  MapView.swift
//  Weather
//
//  Created by jassak on 30/11/2020.
//  Copyright © 2020 jassak1. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var mapType:MapData
    @ObservedObject var weatherFetch:WeatherFetch
    @ObservedObject var weatherData:WeatherData
    
    var body: some View {
            VStack(){
                ShowMap(spanDelta: 2.0, Latitude: mapType.currentLatitude, Longitude: mapType.currentLongitude, mapType: mapType).edgesIgnoringSafeArea(.top)
                HStack {
                    Picker(selection:$mapType.mapType,label:Text("Choose Map")){
                        Text("standardSwitch").tag(0)
                        Text("hybridSwitch").tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                    Button(action:{
                        mapType.locationManager.startUpdatingLocation()
                    }){
                        Image(systemName: "location").padding(.leading,100)
                    }
                }.padding()
            }
            .sheet(isPresented: $mapType.sheetActive, content: {
                WeatherView(equalname: mapType.geoName, weatherFetch: mapType.fetchData, weatherData: weatherData)
            })
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(mapType: MapData(), weatherFetch: WeatherFetch(), weatherData: WeatherData())
    }
}

struct ShowMap: UIViewRepresentable {
    var spanDelta:Double
    var Latitude:Double
    var Longitude:Double
    @ObservedObject var mapType:MapData
    func makeUIView(context: Context) -> MKMapView {
        let myMap = MKMapView(frame: .zero)
        let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(EntireMapViewCoordinator.addAnnotation(gesture:)))
                    longPress.minimumPressDuration = 1
                    myMap.addGestureRecognizer(longPress)
                    myMap.delegate = context.coordinator
                    return myMap
    }

    func makeCoordinator() -> EntireMapViewCoordinator {
        return EntireMapViewCoordinator(self, mapType: mapType)
        }

    class EntireMapViewCoordinator: NSObject, MKMapViewDelegate {
        @ObservedObject var mapType:MapData
            var entireMapViewController: ShowMap
        
        init(_ control: ShowMap, mapType:MapData) {
            self.entireMapViewController = control
            self.mapType=mapType
        }
        
        @objc func addAnnotation(gesture: UIGestureRecognizer) {
            
            if gesture.state == .ended {
                    if let mapView = gesture.view as? MKMapView {
                    let point = gesture.location(in: mapView)
                    let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
                    let annotation = MKPointAnnotation()
                        getCity(oLatitude:coordinate.latitude,oLongitude: coordinate.longitude){city in
                            annotation.title=city
                        }
                    annotation.coordinate = coordinate
                    mapView.addAnnotation(annotation)
                    }
                }
            }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier="placemark"
            var annotationView=mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView==nil{
                annotationView=MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else{
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let placemark = view.annotation as? MKPointAnnotation else { return }
            mapType.reverseLongitude=placemark.coordinate.longitude
            mapType.reverseLatitude=placemark.coordinate.latitude
            mapType.geoName=placemark.title ?? "NA"
            mapType.sheetActive = true
        }
        
        func getCity(oLatitude:Double,oLongitude:Double,completion: @escaping (String) -> Void) {
            let address = CLGeocoder.init()
                address.reverseGeocodeLocation(CLLocation.init(latitude: oLatitude, longitude:oLongitude)) { (places, error)  in
                    if error == nil{
                        if let place = places{
                            completion(place[0].locality ?? "NA")
                        }
                    }
                }
        }
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let coordinate = CLLocationCoordinate2D(
            latitude: Latitude, longitude: Longitude)
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)
        switch mapType.mapType {
        case 0:
            uiView.mapType = .standard
        case 1:
            uiView.mapType = .hybrid
        default:
            uiView.mapType = .standard
        }
    }
}

