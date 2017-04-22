//
//  ExtendUserDefaults.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 02/04/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//
import UIKit

extension UserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData
        }
        set(colorData, forKey: key)
    }
    
}
