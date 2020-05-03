//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Mustafa on 26/04/2020.
//  Copyright © 2020 Home. All rights reserved.
//

import Foundation

struct WeatherModel: Codable {
    let weather: [Weather]
    let main: Main
    let name: String
}

struct Weather: Codable {
    let description: String
    let id: Int
}

struct Main: Codable {
    let temp: Double
}
