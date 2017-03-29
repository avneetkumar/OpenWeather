//
//  OWMFetch.swift
//  Open Weather
//
//  Created by Avneet Kumar on 20/03/17.
//  Copyright © 2017 Avneet Kumar. All rights reserved.
//
//  API key = 60878848ba0ea061df60b1aae97fa39b
//

import Foundation

class OWMFetch{
    
    var json:[String:Any]?
    var urlComponents: URLComponents
    
    var data:Data?
    var jsonData = [String:Any]()

    // Initialize URLComponents to fetch weather data.
    init(withCityID:Int)
    {
        urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "api.openweathermap.org"
        urlComponents.path = "/data/2.5/weather"
        
        let id = URLQueryItem(name: "id", value: String(withCityID))
        let units = URLQueryItem(name: "units", value: "metric")
        let appid = URLQueryItem(name: "APPID", value: "60878848ba0ea061df60b1aae97fa39b")
        urlComponents.queryItems = [id, units, appid];
        
        do
        {
            self.data = try Data(contentsOf: urlComponents.url!)
            if self.data != nil
            {
                self.jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            }
        }
        catch let error as NSError
        {
            print(error)
        }
    }
    
    //This Function will load the weather details (id, main, description, icon) from JSON Query ...
    func getWeather() -> [String:String]
    {
        var weather = [String:String]()
        
        if let jsonWeather = jsonData["weather"] as? [[String:Any]], !jsonWeather.isEmpty
        {
            let description = jsonWeather[0]["description"] as! String
            weather["weather"] = description.capitalized
            
            let icon = jsonWeather[0]["icon"] as! String
            weather["icon"] = icon
        }
        
        if let name = jsonData["name"] as? String
        {
            weather["name"] = name
        }
        
        return weather
    }

    //
    func getMain() -> [String:Double]
    {
        
        var main = [String:Double]()
        
        //Getting data from "main"
        if let jsonMain = jsonData["main"] as? [String:Any]
        {
            let temp = jsonMain["temp"] as! Double
            main["temp"] = temp
            
            let humidity = jsonMain["humidity"] as! Double
            main["humidity"] = humidity
            
            let pressure = jsonMain["pressure"] as! Double
            main["pressure"] = pressure
        }
        
        //Getting information from "wind"
        if let jsonWind = jsonData["wind"] as? [String:Any]
        {
            let speed = jsonWind["speed"] as! Double
            main["speed"] = speed
            
            let deg = jsonWind["deg"] as! Double
            main["deg"] = deg
        }
        
        //Getting information from "clouds"
        if let jsonCloud = jsonData["clouds"] as? [String:Any]
        {
            let cloud = jsonCloud["all"] as! Double
            main["cloud"] = cloud
        }
        
        //Getting information form "rain" rain volume in last 3hrs.
        if let jsonRain = jsonData["rain"] as? [String:Any]
        {
            let rain = jsonRain["3h"] as! Double
            main["rain"] = rain
        }
        
        //Getting information form "rain" rain volume in last 3hrs.
        if let jsonSys = jsonData["sys"] as? [String:Any]
        {
            let sunrise = jsonSys["sunrise"] as! Double
            main["sunrise"] = sunrise
            
            let sunset = jsonSys["sunset"] as! Double
            main["sunset"] = sunset
        }
        
        return main
    }
}
