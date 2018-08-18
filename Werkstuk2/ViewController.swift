//
//  ViewController.swift
//  Werkstuk2
//
//  Created by Felix Struelens on 18/08/18.
//  Copyright © 2018 Felix Struelens. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var annotations = [Annotation]()
    
    let dispatchGroup = DispatchGroup()
    
    @IBOutlet var button: UIButton!
    @IBOutlet var label: UILabel!
    @IBOutlet var map: MKMapView!
    
    @IBAction func buttonAction(_ sender: Any) {
        dispatchGroup.enter()
        self.label.text = "Last update: " + vandaag()
        self.showData(dataSet: self.annotations)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = "Last update:"  + vandaag()
        
        dispatchGroup.enter()
        getJSON()
        dispatchGroup.wait()
        dispatchGroup.enter()
        showData(dataSet: annotations)
    }
    
    func showData(dataSet: [Annotation]){
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        for annotation in dataSet {
            map.addAnnotation(annotation)
        }
        dispatchGroup.leave()
    }
    
    func vandaag() -> String{
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        let today_string = String(day!) + "/" + String(month!) + "/" + String(year!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        return today_string
    }
    
    func getJSON(){
        let url = URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")
        let urlRequest = URLRequest(url: url!)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            var latitude:Double = 0.0
            var longitude:Double = 0.0
            
            guard error == nil else {
                print("error GET")
                print(error!)
                return
            }
            guard let responseData = data else {
                print("geen data beschikbaar")
                return
            }
            guard let stations = try? JSONSerialization.jsonObject(with: responseData, options: []) as! [AnyObject] else {
                print("kan data niet lezen")
                return
            }
            
            for value in stations {
                let status = value["status"] as? String
                let name = value["name"] as? String
                for (positions,coordinates) in (value["position"] as? NSDictionary)!{
                    if positions as! String == "lat"{
                        latitude = coordinates as! Double
                    }
                    if positions as! String == "lng"{
                        longitude = coordinates as! Double
                    }
                }
                let annotation = Annotation(title: name!, subtitle: status!, coordinate: CLLocationCoordinate2DMake(latitude,longitude))
                self.annotations.append(annotation)
            }
            self.dispatchGroup.leave()
        }
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

