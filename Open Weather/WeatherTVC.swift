//
//  WeatherTVC.swift
//  Open Weather
//
//  Created by Avneet Kumar on 16/03/17.
//  Copyright © 2017 Avneet Kumar. All rights reserved.
//

/*
 http://api.openweathermap.org/data/2.5/weather?id=4163971&units=metric&APPID=60878848ba0ea061df60b1aae97fa39b
 */

import UIKit

class WeatherTVC: UITableViewController {
    
    let cities:[String:Int] = ["Sydney" : 2147714, "Melbourne" : 2158177, "Brisbane" : 2174003]
    var weatherData = [String:Double]()//[String: [String:Double]]()
    
    var selectedCity = ""
    var selectedCityID = 1
    
    // Spinner to show during network download
    var indicatorView = UIVisualEffectView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupIndicatorView(inFrame: self.view.frame)
        
        // Using Dispatch Queue to fetch data without blocking main queue.
        let queue = DispatchQueue(label: "dataFetch")
        queue.async {
            for key in self.cities.keys
            {
                self.getTemperature(forCityID: self.cities[key]!, city: key)
            }
            
            //Creating a minimum 1 second delay to dismiss activity inidcator.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute:{
                self.indicatorView.removeFromSuperview()
                self.tableView.reloadData()
            })
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        let citiesArray = [String](cities.keys)
        let city:String = citiesArray[indexPath.row]
        
        (cell.viewWithTag(10) as! UILabel).text = citiesArray[indexPath.row]
        
        if let weatherDict = weatherData[city]
        {
            (cell.viewWithTag(20) as! UILabel).text = String(format:"%.1f" ,weatherDict)
        }
        else
        {
            (cell.viewWithTag(20) as! UILabel).text = "0.0"
        }
        
        return cell
    }
    
    // MARK: - Helper Methods
    
    func getTemperature(forCityID cityID:Int, city:String){
        
        let weatherDataFetcher = OWMFetch(withCityID: cityID)
        let weatherDetails = weatherDataFetcher.getMain()
        
        if let temperature = weatherDetails["temp"]
        {
            weatherData[city] = temperature
        }
    }
    
    //Create a loading indicator centered in superview
    func setupIndicatorView(inFrame frame: CGRect)
    {
        let origin = CGPoint(x: frame.size.width/2 - 50, y: frame.size.height/2 - 50)
        let size = CGSize(width: 100, height: 100)
        indicatorView = UIVisualEffectView(frame: CGRect(origin: origin, size: size))
        indicatorView.effect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        
        indicatorView.layer.cornerRadius = 10.0
        indicatorView.layer.masksToBounds = true
        
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: size.width/2 - 15, y: size.height/2 - 15, width: 30, height: 30))
        activityIndicator.startAnimating()
        
        indicatorView.addSubview(activityIndicator)
        
        self.navigationController?.view.addSubview(indicatorView)
        
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        let weatherDetailsVC = segue.destination as! WeatherDetailsVC
        weatherDetailsVC.cityID = selectedCityID
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let citiesArray = [String](cities.keys)
        selectedCity = citiesArray[indexPath.row]
        
        let citiesID = [Int](cities.values)
        selectedCityID = citiesID[indexPath.row]
        
        self.performSegue(withIdentifier: "weatherDetails", sender:self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
