//
//  WeatherData.swift
//  WeatherTest
//
//  Created by iraniya on 22/08/20.
//  Copyright © 2020 iraniya. All rights reserved.
//

import Foundation

struct WeatherData: Decodable {

    // MARK: - Types
    
    enum CodingKeys: String, CodingKey {
        
        case latitude
        case longitude
        case daily
        case currently
        
    }
    
    enum CurrentlyCodingKeys: String, CodingKey {
        
        case time
        case icon
        case summary
        case windSpeed
        case temperature
        
    }
    
    enum DailyCodingKeys: String, CodingKey {
        
        case data
        
    }
    
    // MARK: - Properties
    
    let time: Date

    // MARK: -
    
    let latitude: Double
    let longitude: Double
    let windSpeed: Double
    let temperature: Double
    
    // MARK: -
    
    let icon: String
    let summary: String
    
    
    // MARK: - Initialization

    init(from decoder: Decoder) throws {
        // Container
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Latitude and Longitude
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        

        // Nested Container: Currently
        let currently = try container.nestedContainer(keyedBy: CurrentlyCodingKeys.self, forKey: .currently)
        
        // Time
        self.time = try currently.decode(Date.self, forKey: .time)
        
        // Wind Speed and Temperature
        self.windSpeed = try currently.decode(Double.self, forKey: .windSpeed)
        self.temperature = try currently.decode(Double.self, forKey: .temperature)
        
        // Icon and Summary
        self.icon = try currently.decode(String.self, forKey: .icon)
        self.summary = try currently.decode(String.self, forKey: .summary)
    }
    
}
