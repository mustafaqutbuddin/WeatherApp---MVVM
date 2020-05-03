//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Mustafa on 26/04/2020.
//  Copyright © 2020 Home. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    //properties
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    
    //instance variables
    private var locationManager = CLLocationManager()
    private var currentLatitude = CLLocationDegrees()
    private var currentLongitude = CLLocationDegrees()
    private var defaultUnit = String()
    
    //viewmodel accessor property
    private var weatherVM: WeatherViewModel? {
        didSet {
            self.cityLabel.text = weatherVM?.cityName
            self.tempLabel.text = String(format: "%.0f", weatherVM!.temperature)
            self.weatherImage.image = UIImage(systemName: weatherVM!.weatherImage)
            self.unitSegmentedControl.selectedSegmentIndex = weatherVM!.setSelectedSegmentedControl()
            self.unitLabel.text = weatherVM?.unitLabel
        }
    }
    
    //MARK: - Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        getUserDefaultOnLaunch()
        requestUserLocation()
    }
    
    //MARK: - Util
    func getUserDefaultOnLaunch() {
        let userDefaults = UserDefaults.standard
        defaultUnit = userDefaults.string(forKey: "unit")!
    }
    
    //MARK: - IBActions
    @IBAction func searchPressed(_ sender: UIButton) {
        locationTextField.endEditing(true)
    }
    
    @IBAction func onUnitChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            weatherVM?.updateUnit(toUnit: .celsius)
        case 1:
            weatherVM?.updateUnit(toUnit: .fahrenheit)
        default:
            print("default")
        }
    }
    
    //MARK: - Networking
    private func fetchWeatherData(withCityName cityName: String) {
        guard let weatherURL = URL(string: ApiConstants.baseURL + "weather?appid=" + AppConstants.WEATHER_API_KEY  + "&units=\(weatherVM?.selectedUnit.rawValue ?? defaultUnit)&q=\(cityName)") else {
            print(URL(string: ApiConstants.baseURL + "weather?appid=" + AppConstants.WEATHER_API_KEY  + "&units=\(weatherVM?.selectedUnit.rawValue ?? defaultUnit)&q=\(cityName)"))
            return
        }
        
        let resource = Resource<WeatherModel>(url: weatherURL)
        callNetworkApi(withResource: resource)
        
    }
    
    private func fetchWeatherData(withLat lat: CLLocationDegrees, withLong long: CLLocationDegrees) {
        guard let weatherURL = URL(string: ApiConstants.baseURL + "weather?appid=" + AppConstants.WEATHER_API_KEY  + "&units=\(weatherVM?.selectedUnit.rawValue ?? defaultUnit)&lat=\(lat)&lon=\(long)") else {
            fatalError("URL was incorrect")
        }
        
        let resource = Resource<WeatherModel>(url: weatherURL)
        callNetworkApi(withResource: resource)
    }
    
    private func callNetworkApi(withResource resource: Resource<WeatherModel>) {
        Webservice().load(resource: resource) { result in
            switch result {
            case .failure(let error):
                print(error)
                
            case .success(let weather):
                print(weather)
                self.weatherVM = WeatherViewModel(weather)
            }
        }
    }
}
//MARK: - Textfield delegate
extension WeatherViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    //always write textfield related validations in below method
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            textField.placeholder = "Type something"
            return false
        } else {
            return true
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        fetchWeatherData(withCityName: textField.text!)
    }
}

//MARK - Current Location
extension WeatherViewController: CLLocationManagerDelegate {
    
    private func requestUserLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    @IBAction func currentLocationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            self.currentLatitude = location.coordinate.latitude
            self.currentLongitude = location.coordinate.longitude
            fetchWeatherData(withLat: self.currentLatitude, withLong: self.currentLongitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
