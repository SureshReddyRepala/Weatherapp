//
//  Utility.swift
//  Weather
//
//  Created by Suresh Reddy on 8/10/24.
//

import Foundation

class Utility {
        
    // Get a formatted date string from a given timestamp
    static func getDateFromTimeStamp(timeStamp: Double, timeFormat: TimeFormat = .none) -> String {
        let date = NSDate(timeIntervalSince1970: timeStamp)
        let dayTimePeriodFormatter = DateFormatter()
        
        var dateFormat = ""
        switch timeFormat {
        case .timeOnly:
            dateFormat = "HH:mm"
        case .dateOnly:
            dateFormat = "MMM dd, yyyy"
        case .none:
            dateFormat = "EEEE, MMM dd, yyyy"
        }
        dayTimePeriodFormatter.dateFormat = dateFormat
        
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        
        return dateString
    }
    
    // Convert temperature from Kelvin to Celsius
    class func kelvinToCelsius(kelvin: Double) -> Double {
        let celsius = kelvin - 273.15
        return celsius
    }
}
