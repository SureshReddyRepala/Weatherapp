//
//  NetworkManager.swift
//  Weather
//
//  Created by Suresh Reddy on 8/10/24.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol {
    
    func getCityWeatherData(cityName: String, completion: @escaping (Result<WeatherData?, Error>) -> Void)
    func getWeatherStatus(iconName: String, completion: @escaping (UIImage?) -> ())
    
}

class NetworkManager: NetworkServiceProtocol {
    
    func getCityWeatherData(cityName: String, completion: @escaping (Result<WeatherData?, Error>) -> Void) {
        
        // Check cache first
        if let cachedData = CacheManager.shared.getCacheCityWeatherData(cityName: cityName) {
            completion(.success(cachedData))
            return
        }
        
        // If not available, get it from source
        self.get(url: Constant.OWM_CITY_WEATHER_DATA_BASEURL, params: ["q": "\(cityName)", "appid": Constant.OWM_API_KEY]) { result in
            
            switch result {
            case .success(let data):
                do {
                    let model = try JSONDecoder().decode(WeatherData.self, from: data!)
                    
                    // Save data to cache
                    CacheManager.shared.saveCityWeatherData(cityName: cityName, data: model)
                    
                    completion(.success(model))
                } catch let err {
                    completion(.failure(NetworkError.decodingError(err: err.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Performs a GET request with specified parameters
    func get(url: String, params: [String: String], complete: @escaping (Result<Data?,Error>) -> ()) {
        
        // Create URLComponents from the given URL
        guard var components = URLComponents(string: url) else {
            print("Error: cannot create URLCompontents")
            complete(.failure(NetworkError.error(err: "URLComponents error")))
            return
        }
        
        // Map the parameters to URLQueryItems
        components.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        
        // Create URL from the components
        guard let url = components.url else {
            print("Error: cannot create URL")
            complete(.failure(NetworkError.error(err: "Error: cannot create URL")))
            return
        }
        
        // Create a URLRequest with the URL and set the HTTP method to GET
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Create an ephemeral URLSession configuration to prevent caching
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        
        // Perform a data task with the created request
        session.dataTask(with: request) { data, response, error in
            
            // Check for errors
            guard error == nil else {
                if let error = error {
                    complete(.failure(error))
                }
                return
            }
            
            // Check if response is valid
            guard let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode == 200 else {
                complete(.failure(NetworkError.invalidResponse))
                return
            }
            
            // Check if data was received
            guard let data = data else {
                complete(.failure(NetworkError.invalidData))
                return
            }
            
            // Call the completion handler with success status and data
            complete(.success(data))
            
        }.resume()
    }
    
    func getWeatherStatus(iconName: String, completion: @escaping (UIImage?) -> ()) {
        
        // Check cache first
        if let cachedImage = CacheManager.shared.getCacheWeatherStatusIcon(imageName: iconName) {
            completion(cachedImage)
            return
        }
        
        // If not available, download it from source
        guard let url = URL(string:Constant.OWM_CITY_WEATHER_STATUS_ICON_BASEURL + iconName + "@2x.png") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading image data: \(error)")
                
                DispatchQueue.main.async {
                    AlertHelperClass.showAlert(in: nil, title:Constant.ERROR, message: error.localizedDescription, preferredStyle: .alert, buttonTitles: [Constant.OK]) { selectedIndex in
                        // Handle the selected index (button) here
                        print("Selected index: \(selectedIndex)")
                        // You can perform different actions based on the selectedIndex.
                    }
                }
                
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                
                // Save data to cache
                CacheManager.shared.saveWeatherStatusIcon(imageName: iconName, imageToCache: image)
                completion(image)
            }
        }.resume()
    }
}
