//
//  UserLocation.swift
//  WeatherTest
//
//  Created by iraniya on 22/08/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class UserLocation: NSObject, MKAnnotation {
    
    //MARK: - Properties
    let title: String?
    let locationName: String?
    let coordinate: CLLocationCoordinate2D
    
    
    //MARK: -
    
    init(title: String?, locationName: String?,  coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    
    init?(feature: MKGeoJSONFeature) {
        guard let point = feature.geometry.first as? MKPointAnnotation,
            let propertiesData = feature.properties,
            let json = try? JSONSerialization.jsonObject(with: propertiesData),
            let properties = json as? [String: Any]
            else {
                fatalError("Unable to parse JSON Data")
                return nil
        }
        
        title = properties["title"] as? String
        locationName = properties["location"] as? String
        coordinate = point.coordinate
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
    var mapItem: MKMapItem? {
        guard let location = locationName else {
            return nil
        }
        
        let addressDict = [CNPostalAddressStreetKey: location]
        let placemark = MKPlacemark( coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
