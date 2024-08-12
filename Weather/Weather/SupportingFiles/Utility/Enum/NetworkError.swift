//
//  NetworkError.swift
//  Weather
//
//  Created by Suresh Reddy on 8/10/24.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case invalidData
    case decodingError(err: String)
    case error(err: String)
}
