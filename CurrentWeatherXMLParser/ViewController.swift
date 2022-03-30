//
//  ViewController.swift
//  CurrentWeather
//
//  Created by Aliaksei Safronau EPAM on 25.03.22.
//

import UIKit

class ViewController: UIViewController {
    
    let currentWeatherRequest = "https://api.weatherapi.com/v1/current.xml?key=43316cabcd794bbabdd134904222503&q=Minsk&aqi=no"
    var weather: WeatherInfo?
    var xmlDict = [String: Any]()
    var currentElement = ""
    
    let imageView: CustomImageView = {
        let im = CustomImageView()
        im.translatesAutoresizingMaskIntoConstraints = false
        im.contentMode = .scaleAspectFill
        im.clipsToBounds = true
        im.layer.cornerRadius = 12
        return im
    }()
    
    let conditionLabel: UILabel = {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.textColor = .black
        return lab
    }()
    
    let lastUpdatedLabel: UILabel = {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.textColor = .black
        return lab
    }()
    
    let locationLabel: UILabel = {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.textColor = .black
        return lab
    }()
    
    let tempLabel: UILabel = {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.textAlignment = .center
        lab.numberOfLines = 0
        lab.textColor = .black
        return lab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(imageView)
        self.view.addSubview(conditionLabel)
        self.view.addSubview(tempLabel)
        self.view.addSubview(locationLabel)
        self.view.addSubview(lastUpdatedLabel)
        self.setupConstraints()
        
        self.loadWeather()
    }
    
    private func updateUI() {
        guard let weather = weather else {return}
        self.imageView.loadImageUseingUrlString(urlString: "https:\(weather.conditionIconUrl)")
        self.lastUpdatedLabel.text = "Last Updated: \(weather.lastUpdated)"
        self.locationLabel.text = "Location: \(weather.location)"
        self.tempLabel.text = "Temperature: \(weather.temperature)"
        self.locationLabel.text = "Location: \(weather.location)"
        self.conditionLabel.text = "Current weather is \(weather.conditionText)"
    }
    
    private func loadWeather() {
        let downloadDataOperation = DownloadDataOperation()
        downloadDataOperation.qualityOfService = .userInitiated
        downloadDataOperation.urlString = currentWeatherRequest
        downloadDataOperation.start()
        downloadDataOperation.completionBlock = { [weak self] in
            guard
                let self = self,
                let data = downloadDataOperation.downloadedData
            else {return}
            DispatchQueue.main.async {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        }
    }
    
    private func setupConstraints(){
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        conditionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
        conditionLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        tempLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor).isActive = true
        tempLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        locationLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor).isActive = true
        locationLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        lastUpdatedLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor).isActive = true
        lastUpdatedLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100).isActive = true
        lastUpdatedLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
}

extension ViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if xmlDict[currentElement] == nil {
                xmlDict.updateValue(string, forKey: currentElement)
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parsingCompleted()
    }
    
    func parsingCompleted() {
        self.weather = WeatherInfo(details: self.xmlDict)
        self.updateUI()
    }
}

class CustomImageView: UIImageView {
    
    func loadImageUseingUrlString(urlString: String){
        image = nil
        let downloadImageOperation = DownloadImageOperation()
        downloadImageOperation.qualityOfService = .userInitiated
        downloadImageOperation.urlString = urlString
        downloadImageOperation.start()
        downloadImageOperation.completionBlock = { [weak self] in
            guard
                let self = self,
                let downloadedImage = downloadImageOperation.downloadedImage
            else {return}
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }
    }
}
