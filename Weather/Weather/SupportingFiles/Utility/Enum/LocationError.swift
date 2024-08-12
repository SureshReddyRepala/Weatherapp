//
//  LocationError.swift
//  Weather
//
//  Created by Suresh Reddy on 8/10/24.
//

import Foundation

enum LocationError: Error {
    case noLocationAvailable
    case noCityAvailable
    case noPlacemarkAvailable
    case locationUnknown
    case denied
    case coreLocationError
}
