//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Suresh Reddy on 8/10/24.
//

import Foundation
import UIKit


class WeatherViewModel: ObservableObject{
    
    //MARK: - Var(s)
    
    // NetworkManager instance for making API requests
    let networkManager = NetworkManager()
    
    // Callback to notify the UI when data updates
    var showWeatherData: ((WeatherData?) -> Void)?
    
    // Callback to notify the UI when image updates
    var showWeatherStatusIcon: ((UIImage?) -> Void)?
    
    @Published  var cityWeatherData: WeatherData? {
        didSet {
            // Trigger UI update when current city weather data is set
            if let weatherData = self.cityWeatherData {
                self.showWeatherData?(weatherData)
            }
        }
    }
    
    var cityWeatherStatusIcon: UIImage? {
        didSet {
            // Trigger UI update when weather status icon is set
            if let weatherStatusIcon = self.cityWeatherStatusIcon {
                self.showWeatherStatusIcon?(weatherStatusIcon)
            }
        }
    }
    
    //MARK: - Helper Method(s)
    
    // Fetch current weather data for a specific city
    func getCityWeatherData(city: String, completion: @escaping (Result<WeatherData?, Error>) -> Void)  {
        
        networkManager.getCityWeatherData(cityName: city) { result in
            
            switch result {
            case .success(let weatherData):
                
                // Fetch the corresponding weather status icon
                if let iconName = weatherData?.weather.first?.icon {
                    self.getWeatherStatusImage(name: iconName)
                }
                DispatchQueue.main.async {
                    self.cityWeatherData = weatherData
                }
                
                completion(.success(weatherData))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Fetch current weather status icon
    func getWeatherStatusImage(name: String) {
        
        networkManager.getWeatherStatus(iconName: name) { image in
            
            if let weatherStatusImage = image {
                
                self.cityWeatherStatusIcon = weatherStatusImage
            }
        }
    }
    
    // Fetch last searched weather data
    func getLastSearchedCityWeatherData(city: String) {
        
        if let cachedData = CacheManager.shared.getCacheCityWeatherData(cityName: city) {
            
            self.cityWeatherData = cachedData
            
            if let iconName = self.cityWeatherData?.weather.first?.icon {
                self.getWeatherStatusImage(name: iconName)
            }
        }
    }
}
