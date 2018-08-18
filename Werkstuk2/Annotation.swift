//
//  Annotation.swift
//  Werkstuk2
//
//  Created by Felix Struelens on 18/08/18.
//  Copyright © 2018 Felix Struelens. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    override init() {
        title = ""
        subtitle = ""
        coordinate = CLLocationCoordinate2D()
    }
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}
