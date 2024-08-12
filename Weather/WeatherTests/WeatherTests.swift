//
//  WeatherTests.swift
//  WeatherTests
//
//  Created by Suresh Reddy on 8/10/24.
//

import XCTest
@testable import Weather

final class WeatherTests: XCTestCase {

    //system under test
    var sut: URLSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = URLSession(configuration: .ephemeral)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGivenOpenWeatherMapEndPoint_whenMakingGeocodingAPICallByCityName_thenReceivingWeatherData() {
       
        // Given
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=London&appid=0f1ceaea012447ca76079f689a8a6666")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        //What we expect to happen
        let promise = expectation(description: "Weather Data Received")

        // when
        sut.dataTask(with: request) { data, response, error in
            
            // then
            guard error == nil else {
                XCTFail("API call failed with error: \(String(describing: error))")
                return
            }
            // Check if data was received
            guard data != nil else {
                XCTFail("Error: did not receive data")
                return
            }
            
            // Check if response is valid
            guard let httpUrlResponse = response as? HTTPURLResponse, httpUrlResponse.statusCode == 200 else {
                XCTFail("Error: HTTP request failed:\(String(describing: response))")
                return
            }
            
            promise.fulfill()
            
        }.resume()
        
        //Keeps the test running until all expectations are fulfilled, or the timeout interval ends, whichever happens first
        wait(for: [promise], timeout: 5)
        
    }
    
    func testGivenOpenWeatherMapEndPoint_whenMakingWeatherIconAPICallWithIconName_thenReceivingWeatherStatusIconData() {
       
        // Given
        guard let url = URL(string: "https://openweathermap.org/img/wn/10d@2x.png") else { return }
        
        //What we expect to happen
        let promise = expectation(description: "Weather Status Icon Data Received")

        // When
        sut.dataTask(with: url) { data, _, error in
            
            // Then
            if let error = error {
                XCTFail("Error downloading image data: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                promise.fulfill()
            }
        }.resume()
        
        //Keeps the test running until all expectations are fulfilled, or the timeout interval ends, whichever happens first
        wait(for: [promise], timeout: 5)
        
    }
}
