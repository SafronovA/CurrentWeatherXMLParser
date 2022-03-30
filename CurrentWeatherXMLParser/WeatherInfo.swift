//
//  WeatherInfo.swift
//  CurrentWeather
//
//  Created by Aliaksei Safronau EPAM on 30.03.22.
//

import Foundation

struct WeatherInfo {
    var location: String
    var lastUpdated: String
    var temperature: String
    var conditionText: String
    var conditionIconUrl: String
    
    init(details: [String: Any]) {
        location = details["tz_id"] as? String ?? ""
        lastUpdated = details["last_updated"] as? String ?? ""
        temperature = details["temp_c"] as? String ?? ""
        conditionText = details["text"] as? String ?? ""
        conditionIconUrl = details["icon"] as? String ?? ""
    }
}
