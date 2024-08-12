//
//  CacheManager.swift
//  Weather
//
//  Created by Suresh Reddy on 8/10/24.
//

import Foundation
import UIKit

class CacheManager {
    
    // Singleton instance of CacheManager
    public static let shared = CacheManager()
    
    // Private initializer for Singleton pattern
    private init() {}
    
    // UserDefaults instance for data persistence
    private let userDefaults = UserDefaults.standard
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    // Save current city weather data to UserDefaults
    func saveCityWeatherData(cityName: String, data: WeatherData) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            
            // Removing last searched City data from UserDefaults before saving current one
            if let lastlySearchedCity = userDefaults.value(forKey: "lastSearch") as? String{
                
                UserDefaults.standard.removeObject(forKey: "CityWeather_\(lastlySearchedCity)")
            }
            
            userDefaults.set(encodedData, forKey: "CityWeather_\(cityName)")
            userDefaults.setValue(cityName, forKey: "lastSearch")
        } catch {
            print("Error encoding CityWeather data: \(error.localizedDescription)")
        }
    }
    
    // Retrieve cached current city weather data from UserDefaults
    func getCacheCityWeatherData(cityName: String) -> WeatherData? {
        
        if let encodedData = userDefaults.data(forKey: "CityWeather_\(cityName)") {
            do {
                let decodedData = try JSONDecoder().decode(WeatherData.self, from: encodedData)
                userDefaults.setValue(cityName, forKey: "lastSearch")
                return decodedData
            } catch let error {
                print("Error decoding CityWeather data: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    AlertHelperClass.showAlert(in: nil, title:Constant.ERROR, message: error.localizedDescription, preferredStyle: .alert, buttonTitles: [Constant.OK]) { selectedIndex in
                        // Handle the selected index (button) here
                        print("Selected index: \(selectedIndex)")
                        // You can perform different actions based on the selectedIndex.
                    }
                }
            }
        }
        return nil
    }
    
    // Save weather status image to Cache
    func saveWeatherStatusIcon(imageName: String, imageToCache: UIImage) {
        self.imageCache.setObject(imageToCache, forKey: imageName as AnyObject)
    }
    
    // Retrieve cached weather status image
    func getCacheWeatherStatusIcon(imageName: String) -> UIImage? {
        
        if let imageFromCache = imageCache.object(forKey: imageName as AnyObject) as? UIImage {
            return imageFromCache
        }
        return nil
    }
}
