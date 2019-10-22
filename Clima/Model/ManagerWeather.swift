//
//  ManagerWeather.swift
//  Clima
//
//  Created by Артём Шишкин on 19.10.2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import Foundation


protocol WeatherManagerDelegate {
    func didUpdateWeather (_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}
struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let wetherURL = "https://api.openweathermap.org/data/2.5/weather?appid=24c25a726b2b305c6bbbc39faf1370ac&units=metric"
    
    func fetchWeather (cityName:String) {
        let urlString = "\(wetherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "\(wetherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, responce, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temperature = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temperature)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
   
    
}
