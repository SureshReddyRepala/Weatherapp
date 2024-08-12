//
//  ViewController.swift
//  Weather
//
//  Created by Suresh Reddy on 8/10/24.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - IBOutlet(s)
    @IBOutlet weak var lblCity: UILabel?
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgWeatherStatusPic: UIImageView?
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblWeatherDescription: UILabel!
    @IBOutlet weak var lblFeelsLike: UILabel!
    
    
    //MARK: - Var(s)
    
    // Lazy instantiation of the WeatherViewModel
    lazy var viewModel = {
        WeatherViewModel()
    }()
    
    var currentWeatherData: WeatherData?
    var currentWeatherStatusIcon: UIImage?
    let locationManager = LocationManager.shared
    
    //MARK: - Life Cycle Method(s)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewModel()
        self.addSwiftUIView()
    }
    
    //MARK: - Action Method(s)
    
    func addSwiftUIView() {
        let swiftUIView = SwiftUIView().environmentObject(viewModel)
        addSubSwiftUIView(swiftUIView, to: view)
    }
    
    // onSearch: Displays an alert for city search
    @IBAction func onSearch(_ sender: Any) {
        // Create an alert controller
        let alertController = UIAlertController(title: Constant.SEARCH, message: Constant.ENTER_CITY_NAME, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = Constant.CITY
        }
        
        let searchAction = UIAlertAction(title: Constant.SEARCH, style: .default) { [weak self] (_) in
            if let textField = alertController.textFields?.first, let searchText = textField.text {
                if(!searchText.isEmpty) {
                    self?.performSearch(with: searchText)
                }else{
                    DispatchQueue.main.async {
                        self?.alert(message:Constant.SEARCH_Text_EMPTY)
                    }
                }
            }
        }
        
        // Create the cancel action
        let cancelAction = UIAlertAction(title: Constant.CANCEL, style: .cancel, handler: nil)
        
        // Add the actions to the alert controller
        alertController.addAction(searchAction)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    // performSearch: Initiates a weather search for the specified city
    func performSearch(with cityName: String) {
        
        // Check Internet Connectivity
        if InternetConnectionManager.isConnectedToNetwork(){
            debugPrint("Connected")
            
            self.viewModel.getCityWeatherData(city: cityName) { result in
                switch result {
                case .success(let weatherData):
                    if let cityData = weatherData {
                        self.currentWeatherData = cityData
                    }
                    DispatchQueue.main.async {
                        self.showCityWeatherData()
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.alert(message: error.localizedDescription)
                    }
                }
            }
            
        }else{
            debugPrint("Not Connected")
            DispatchQueue.main.async {
                // Show network unavailability
                self.alert(message: Constant.NO_NETWORK)
            }
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        // Check the current size class
        let horizontalSizeClass = traitCollection.horizontalSizeClass
        let verticalSizeClass = traitCollection.verticalSizeClass
        
        // Adjust layout based on the size classes
        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            // Adjust layout for compact width and regular height (e.g., iPhone portrait)
            print("Compact width, Regular height")
            
            self.view.backgroundColor = .cyan
            lblCity?.font = UIFont.boldSystemFont(ofSize: 25.0)
            lblDate?.font = UIFont.systemFont(ofSize: 17.0)
            
        } else if horizontalSizeClass == .compact && verticalSizeClass == .compact {
            // Adjust layout for compact width and compact height (e.g., iPhone landscape)
            print("Compact width, Compact height")
            
            self.view.backgroundColor = .systemMint
            lblCity?.font = UIFont.boldSystemFont(ofSize: 25.0)
            lblDate?.font = UIFont.systemFont(ofSize: 17.0)
            
        } else if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            // Adjust layout for regular width and regular height (e.g., iPad)
            print("Regular width, Regular height")
            
            self.view.backgroundColor = .systemTeal
            lblCity?.font = UIFont.boldSystemFont(ofSize: 35.0)
            lblDate?.font = UIFont.systemFont(ofSize: 27.0)
            lblTemperature?.font = UIFont.boldSystemFont(ofSize: 40.0)
            lblFeelsLike?.font = UIFont.systemFont(ofSize: 27.0)
            lblWeatherDescription?.font = UIFont.systemFont(ofSize: 27.0)
            
        }
    }
}

//MARK: - UI update and ViewModel Initializer

extension ViewController {
    
    func initViewModel() {
        
        // Callback to show the current weather data
        
        viewModel.showWeatherData = { [weak self] cityData in
            if let cityData = cityData {
                self?.currentWeatherData = cityData
            }
            DispatchQueue.main.async {
                self?.showCityWeatherData()
            }
        }
        
        // Callback to show the current weather status icon
        viewModel.showWeatherStatusIcon = { [weak self] icon in
            if let statusIcon = icon {
                self?.currentWeatherStatusIcon = statusIcon
            }
            DispatchQueue.main.async {
                self?.showCityWeatherStatusImage()
            }
        }
        
        
        if InternetConnectionManager.isConnectedToNetwork(){
            debugPrint("Connected")
            if let lastlySearchedCity = UserDefaults.standard.value(forKey: "lastSearch") as? String{
                self.viewModel.getLastSearchedCityWeatherData(city: lastlySearchedCity)
            }
            else{
                // Fetches the current city using the location manager
                locationManager.getCurrentCity { result in
                    switch result {
                    case .success(let cityName):
                        self.viewModel.getCityWeatherData(city: cityName) { results in
                            switch results {
                            case .success(let weatherData):
                                if let cityData = weatherData {
                                    self.currentWeatherData = cityData
                                }
                                DispatchQueue.main.async {
                                    self.showCityWeatherData()
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    self.alert(message: error.localizedDescription)
                                }
                            }
                        }
                    case .failure(let error):
                        debugPrint("Location update failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.alert(message: Constant.LOCATION_ERROR)
                        }
                    }
                }
            }
        }else{
            debugPrint("Not Connected")
            DispatchQueue.main.async {
                self.alert(message: Constant.NO_NETWORK)
            }
        }
    }
    
    // showCityWeatherData: Updates the UI elements with the current weather data
    func showCityWeatherData() {
        
        if let city = self.currentWeatherData?.name {
            self.lblCity?.text = city
        } else {
            self.lblCity?.text = "NA"
        }
        
        if let timeInterval = self.currentWeatherData?.dt {
            self.lblDate?.text = Utility.getDateFromTimeStamp(timeStamp: timeInterval)
        } else {
            self.lblDate?.text = "NA"
        }
        
        if let temperature = self.currentWeatherData?.main.temp {
            let celsiusTemperature = Utility.kelvinToCelsius(kelvin: temperature)
            self.lblTemperature?.text = String(format: "%.2f °C", celsiusTemperature)
        } else {
            self.lblTemperature?.text = "NA"
        }
        
        if let description = self.currentWeatherData?.weather.first?.description {
            self.lblWeatherDescription?.text = description
        } else {
            self.lblWeatherDescription?.text = "NA"
        }
        
        if let feelsLike = self.currentWeatherData?.main.feelsLike {
            let celsiusFeelsLike = Utility.kelvinToCelsius(kelvin: feelsLike)
            self.lblFeelsLike?.text = String(format: "Feels like %.2f °C", celsiusFeelsLike)
        } else {
            self.lblFeelsLike?.text = "NA"
        }
        
        
        self.addSwiftUIView()
    }
    
    // showCityWeatherStatusImage: Updates the UI element with the current weather status icon
    func showCityWeatherStatusImage() {
        
        if let icon = self.currentWeatherStatusIcon {
            self.imgWeatherStatusPic?.image = icon
        } else {
            // Set Placeholder icon:
            self.imgWeatherStatusPic?.image = UIImage(named: "cloud.sun")
        }
    }
}

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}




