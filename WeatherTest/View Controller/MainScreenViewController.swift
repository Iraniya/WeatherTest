//
//  ViewController.swift
//  WeatherTest
//
//  Created by iraniya on 22/08/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import UIKit
import MapKit

class MainScreenViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: -
    
    private var storeLocations: [UserLocation] = []
    
    private lazy var networkManager = NetworkManager()
    
    private lazy var locationManager: CLLocationManager = {
        // Initialize Location Manager
        let locationManager = CLLocationManager()
        
        // Configure Location Manager
        locationManager.distanceFilter = 1000.0
        locationManager.desiredAccuracy = 1000.0
        
        return locationManager
    }()
    
    private var currentLocation: CLLocation? {
        didSet {
            fetchWeatherData()
        }
    }
    
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request Location
        requestLocation()
        
        //for double tap to open new location
        gestureConfig()
    }
    
    
    func gestureConfig() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        gestureRecognizer.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    //MARK: - Methods
    
    private func updateCurrentLocationWeather(WithweatherData weatherData: WeatherData) {
        
        let currenCLLtLocation = currentLocation ?? CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude) //Or we can show error message saying location not found
        mapView.centerToLocation(currenCLLtLocation)
        
        let locationName: String = ""
        let temperature = weatherData.temperature.toCelcius
        let temperatureString = String(format: "%.1f °C", temperature)
        let weatherString = "\(temperatureString), Wind:\(weatherData.windSpeed),\(weatherData.summary)"
        
        let currentLocation = UserLocation(
            title: "Current Location: \(locationName)",
            locationName: weatherString,
            discipline: "Weather: \(32)",
            coordinate: CLLocationCoordinate2D(latitude: weatherData.latitude, longitude: weatherData.longitude))
        
        mapView.delegate = self
        mapView.addAnnotation(currentLocation)
    }
    
    
    private func requestLocation() {
        // Configure Location Manager
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            // Request Current Location
            locationManager.requestLocation()
        default:
            // Request Authorization
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    //MARk: -
    
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
    
    //MARK: - Actions
    
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {

        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)

//        // Add annotation:
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
        
        let getLat: CLLocationDegrees = coordinate.latitude
        let getLon: CLLocationDegrees = coordinate.longitude

        let getMovedMapCenter: CLLocation =  CLLocation(latitude: getLat, longitude: getLon)

        let selectVC = (UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SelectedLocationViewController") as! SelectedLocationViewController)
        selectVC.currentLocation = getMovedMapCenter
        present(selectVC, animated: true, completion: nil)
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


extension MainScreenViewController: MKMapViewDelegate {
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
    
    
    // MARK: -
    
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


extension MainScreenViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways,
             .authorizedWhenInUse:
            // Request Location
            manager.requestLocation()
        case .denied,
             .restricted:
            // Notify User
            presentAlert(of: .notAuthorizedToRequestLocation)
        default:
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
    }
    
    // MARK: - Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Update Current Location
            currentLocation = location
            
            // Reset Delegate
            manager.delegate = nil
            
            // Stop Location Manager
            manager.stopUpdatingLocation()
            
        } else {
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if currentLocation == nil {
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
        
        // Notify User
        presentAlert(of: .failedToRequestLocation)
    }
}
