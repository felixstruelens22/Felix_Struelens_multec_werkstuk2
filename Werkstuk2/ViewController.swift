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
        self.label.text = NSLocalizedString("Last update", comment: "") + ": " + vandaag()
        self.button.setTitle(NSLocalizedString("Update", comment: ""), for: .normal)
        self.showData(dataSet: self.annotations)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.text = NSLocalizedString("Last update:", comment: "")  + vandaag()
        
        dispatchGroup.enter()
        getJSON()
        dispatchGroup.wait()
        dispatchGroup.enter()
        showData(dataSet: annotations)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let center = CLLocationCoordinate2D(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
        
        mapView.setRegion(region, animated: true)
    }
    
    func showData(dataSet: [Annotation]){
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        for annotation in dataSet {
            map.addAnnotation(annotation)
            map.selectAnnotation(annotation, animated: true)
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
            
            guard error == nil else {
                print(NSLocalizedString("error GET", comment: ""))
                print(error!)
                return
            }
            guard let responseData = data else {
                print(NSLocalizedString("no data", comment: ""))
                return
            }
            guard let stations = try? JSONSerialization.jsonObject(with: responseData, options: []) as! [AnyObject] else {
                print(NSLocalizedString("can not read data", comment: ""))
                return
            }
            
            for value in stations {
                let bikes = NSLocalizedString("available bikes: ", comment: "")
                let name = value["name"] as? String ?? NSLocalizedString("no name available", comment: "")
                let status = value["status"] as? String ?? NSLocalizedString("no status available", comment: "")
                let available_bikes = value["available_bikes"] as? String ?? NSLocalizedString("no bike data available", comment: "")
                var lat:Double = 0.0
                var lng:Double = 0.0
                for (pos,posValue) in (value["position"] as? NSDictionary)!{
                    if pos as! String == "lat"{
                        lat = posValue as! Double
                    }
                    if pos as! String == "lng"{
                        lng = posValue as! Double
                    }
                }
                let annotation = Annotation(title: name, subtitle: status + " - " + bikes + available_bikes, coordinate: CLLocationCoordinate2DMake(lat,lng))
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

