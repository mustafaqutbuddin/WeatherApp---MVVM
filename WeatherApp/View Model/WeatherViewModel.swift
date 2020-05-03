//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Mustafa on 26/04/2020.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation
import UIKit

enum Unit: String {
    case celsius = "metric"
    case fahrenheit = "imperial"
}

struct WeatherViewModel {
    let cityName: String
    var temperature: Double
    let conditionId: Int
    var unitLabel: String
    
    //get / set userdefault values.
    var selectedUnit: Unit {
        get {
            let userDefaults = UserDefaults.standard
            var unitValue = ""
            if let value = userDefaults.string(forKey: "unit") {
                unitValue = value
            }
            return Unit(rawValue: unitValue)!
        }
        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue.rawValue, forKey: "unit")
        }
    }
    
    //change SF Symbol images as per weather codes returned by api
    var weatherImage: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
    
    //initializer
    init(_ weather: WeatherModel) {
        self.cityName = weather.name
        self.temperature = weather.main.temp
        self.conditionId = weather.weather[0].id
        self.unitLabel = "C"
        print(self.selectedUnit)
    }
    
    //update unit upon selection
    mutating func updateUnit(toUnit unit: Unit) {
        switch unit {
        case .celsius:
            toCelsius()
        case .fahrenheit:
            toFahrenhiet()
        }
    }
    
    mutating func toCelsius() {
        self.selectedUnit = .celsius
        self.temperature = (self.temperature - 32) * 5/9
        self.unitLabel = "C"
    }
    
    mutating func toFahrenhiet() {
        self.selectedUnit = .fahrenheit
        self.temperature = (self.temperature * 9/5) + 32
        self.unitLabel = "F"
    }
    
    //update segmented control UI
    mutating func setSelectedSegmentedControl () -> Int {
        switch selectedUnit {
        case .celsius:
            self.unitLabel = "C"
            return 0
        case .fahrenheit:
            self.unitLabel = "F"
            return 1
        }
    }
}
