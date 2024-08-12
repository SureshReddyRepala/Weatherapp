//
//  SwiftUIView.swift
//  Weather
//
//  Created by Suresh Reddy on 8/12/24.
//

import SwiftUI

struct SwiftUIView: View {
    // @ObservedObject var model: WeatherViewModel
    
    @EnvironmentObject var wvmEnvironmentObject:WeatherViewModel
    
    var body: some View {
        HStack{
            VStack{
                Text("Humidity")
                    .padding(10)
                if let humidityValue = wvmEnvironmentObject.cityWeatherData?.main.humidity {
                    Text(String(format: "%d%%",humidityValue))
                        .padding(10)
                }
                
            }.padding(20)
            VStack{
                Text("Pressure")
                    .padding(8)
                if let pressureValue = wvmEnvironmentObject.cityWeatherData?.main.pressure {
                    Text(String(format: "%d%%",pressureValue))
                        .padding(10)
                }
            }.padding(20)
            VStack{
                Text("Visibility")
                    .padding(10)
                if let visibilityValue = wvmEnvironmentObject.cityWeatherData?.visibility {
                    Text(String(format: "%d%%",visibilityValue))
                        .padding(10)
                }
            }.padding(20)
        }
    }
}

#Preview {
    SwiftUIView()
}
