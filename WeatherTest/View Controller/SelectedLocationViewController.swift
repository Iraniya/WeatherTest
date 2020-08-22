//
//  SelectedLocationViewController.swift
//  WeatherTest
//
//  Created by iraniya on 22/08/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import UIKit
import MapKit

class SelectedLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation: CLLocation?
    
    private lazy var networkManager = NetworkManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchWeatherData()
        
    }
    
    
    private func updateCurrentLocationWeather(WithweatherData weatherData: WeatherData) {
        
        let currenCLLtLocation = currentLocation ?? CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude) //Or we can show error message saying location not found
        mapView.centerToLocation(currenCLLtLocation)
        let locationName: String = ""
        let weatherString = "Location: \(locationName), Weather: \(weatherData.temperature), Wind: \(weatherData.windSpeed)\n\(weatherData.summary)"
        
        let currentLocation = UserLocation(
            title: "Current Location",
            locationName: weatherString,
            discipline: "Weather: \(32)",
            coordinate: CLLocationCoordinate2D(latitude: weatherData.latitude, longitude: weatherData.longitude))
        
        mapView.delegate = self
        mapView.addAnnotation(currentLocation)
    }
    
    private func fetchWeatherData() {
        guard let location = currentLocation else {
            return
        }
        
        // Helpers
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Fetch Weather Data for Location
        networkManager.weatherDataForLocation(latitude: latitude, longitude: longitude) { [weak self] (result) in
            switch result {
            case .success(let weatherData):
                // Show weather for current location
                print(weatherData)
                self?.updateCurrentLocationWeather(WithweatherData: weatherData)
            case .failure:
                // Notify User
                self?.presentAlert(of: .noWeatherDataAvailable)
                
                
            }
        }
    }
    
    private func presentAlert(of alertType: AlertType) {
           // Helpers
           let title: String
           let message: String
           
           switch alertType {
           case .notAuthorizedToRequestLocation:
               title = "Unable to Fetch Weather Data for Your Location"
               message = "WeatherTest is not authorized to access your current location. You can grant access to your current location in the Settings application."
           case .failedToRequestLocation:
               title = "Unable to Fetch Weather Data for Your Location"
               message = "WeatherTest is not able to fetch your current location due to a technical issue."
           case .noWeatherDataAvailable:
               title = "Unable to Fetch Weather Data"
               message = "WeatherTest is unable to fetch weather data. Please make sure your device is connected over Wi-Fi or cellular."
           }
           
           // Initialize Alert Controller
           let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
           
           // Add Cancel Action
           let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
           alertController.addAction(cancelAction)
           
           // Present Alert Controller
           present(alertController, animated: true)
       }
}


private extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion( center: location.coordinate,
                                                   latitudinalMeters: regionRadius,
                                                   longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}


extension SelectedLocationViewController: MKMapViewDelegate {
    func mapView( _ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let userLocation = view.annotation as? UserLocation else {
            return
        }
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        userLocation.mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    
    func mapView( _ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? UserLocation else { return nil }
        
        let identifier = "userLocation"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView( withIdentifier: identifier) as? MKMarkerAnnotationView { dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            
            view = MKMarkerAnnotationView(  annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
