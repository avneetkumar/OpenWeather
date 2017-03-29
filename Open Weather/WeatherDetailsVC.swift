//
//  WeatherDetailsVC.swift
//  Open Weather
//
//  Created by Avneet Kumar on 20/03/17.
//  Copyright © 2017 Avneet Kumar. All rights reserved.
//

import UIKit

class WeatherDetailsVC: UIViewController {
    
    var cityID:Int?
    var weatherDetails2 = [String:String]()
    var weatherDetails3 = [String:Double]()
    
    
    @IBOutlet weak var cityLable: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherCondition: UILabel!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var cloudcoverLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    @IBOutlet weak var winddirectionLable: UILabel!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var sunriseView: UIView!
    @IBOutlet weak var sunsetView: UIView!
    @IBOutlet weak var cloudCoverView: UIView!
    @IBOutlet weak var windSpeedView: UIView!
    @IBOutlet weak var windSpeedDirectionView: UIView!
    
    
    // Spinner to show during network download
    var indicatorView = UIVisualEffectView()
    
    //MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Chaning all views alpha to 0 for animation
        let viewsToAnimate = [headerView, sunriseView, sunsetView, cloudCoverView, windSpeedView, windSpeedDirectionView]
        
        for view in viewsToAnimate
        {
            view?.alpha = 0
        }
        
        //Setting up loading indicator view
        setupIndicatorView(inFrame: self.view.frame)
        
        // Using Dispatch Queue to fetch data without blocking main queue.
        let queue = DispatchQueue(label: "dataFetch")
        queue.async {
            
            let dataFetch = OWMFetch(withCityID: self.cityID!)
            self.weatherDetails2 = dataFetch.getWeather()
            self.weatherDetails3 = dataFetch.getMain()
            
            
            //Creating a minimum 1 second delay to dismiss activity inidcator.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), execute:
                {
                    self.indicatorView.removeFromSuperview()
                    self.updateWeatherDetails()
                    self.animateViewsOnScreen()
            })
            
        }
    }
    
    //MARK: - Helper Methods
    
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
        
        self.view.addSubview(indicatorView)
    }
    
    func updateWeatherDetails()
    {
        //Code below to check for existing data and updating lable.
        if let name = weatherDetails2["name"], let temp = weatherDetails3["temp"], let humidity = weatherDetails3["humidity"], let condition = weatherDetails2["weather"]
        {
            cityLable.text = name
            temperatureLabel.text = "Temperature : \(String(format:"%.1f" ,temp))ºC"
            humidityLabel.text = "Humidity : \(String(format:"%.1f" ,humidity))%"
            weatherCondition.text = condition.capitalized
        }
        
        if let sunrise = weatherDetails3["sunrise"], let sunset = weatherDetails3["sunset"]
        {
            var time = Date(timeIntervalSince1970: sunrise)
            sunriseLabel.text = convertDateToString(forDate: time)
            
            time = Date(timeIntervalSince1970: sunset)
            sunsetLabel.text = convertDateToString(forDate: time)
        }
        
        if let cloudCover = weatherDetails3["cloud"]
        {
            cloudcoverLabel.text = String(cloudCover) + "%"
        }
        
        if let windSpeed = weatherDetails3["speed"]
        {
            windspeedLabel.text = String(format:"%.1f" ,windSpeed) + " m/s"
        }
        
        if let windDirection = weatherDetails3["deg"]
        {
            winddirectionLable.text = String(windDirection) + "º"
        }
        
        if let icon = weatherDetails2["icon"]
        {
            loadImage(forIcon: icon)
        }
    }
    
    // Download weather icon and update image view
    func loadImage(forIcon icon:String)
    {
        let url = URL(string: "http://openweathermap.org/img/w/\(icon).png")
        
        // Load Image using URLSession with icon image.
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response,error) in
            
            if data != nil
            {
                let image = UIImage(data: data!)
                
                //Load image in main queue
                DispatchQueue.main.async {
                    self.weatherIcon.image = image
                }
            }
            
        }).resume()
    }
    
    //When called this method animates the alpha view all view from 0 to 1
    func animateViewsOnScreen()
    {
        let viewsToAnimate = [headerView, sunriseView, sunsetView, cloudCoverView, windSpeedView, windSpeedDirectionView]
        var delay = 0.0
        
        for view in viewsToAnimate {
            UIView.animate(withDuration: 0.7, delay:delay , options: [UIViewAnimationOptions.curveEaseOut], animations: {
                view?.alpha = 1
            }, completion: { (bool) in })
            delay += 0.1
        }
    }
    
    //Create a date string with time in correct timezone.
    func convertDateToString(forDate date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
