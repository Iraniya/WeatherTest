//
//  WeatherConfiguration.swift
//  WeatherTest
//
//  Created by iraniya on 22/08/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import Foundation

struct Defaults {
    static let Latitude: Double = 23.112650
    static let Longitude: Double = 72.583618
    static let apiKey = "tnperxfip8renk2hlzcccwetbnesby"
}

// MARK: - Types

enum AlertType {
    case notAuthorizedToRequestLocation
    case failedToRequestLocation
    case noWeatherDataAvailable
    
}


struct WeatherServiceRequest {
    
    // MARK: - Properties
    
    private let apiKey = "tnperxfip8renk2hlzcccwetbnesby"
    private let baseUrl = URL(string: "https://cocoacasts.com/clearsky/")!
    
    // MARK: -
    
    let latitude: Double
    let longitude: Double
    
    // MARK: - Public API
    
    var url: URL {
        // Create URL Components
        guard var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false) else {
            fatalError("Unable to Create URL Components for Weather Service Request")
        }
        
        // Define Query Items
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "long", value: "\(longitude)")
        ]
        
        guard let url = components.url else {
            fatalError("Unable to Create URL for Weather Service Request")
        }
        
        return url
    }
    
}
