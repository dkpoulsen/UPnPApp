//
//  ExtendInt.swift
//  UPnP2Cast
//
//  Created by Daniel K. Poulsen on 13/05/2017.
//  Copyright © 2017 Daniel K. Poulsen. All rights reserved.
//

import Foundation

extension Int{
    func GetRemainingSeconds() -> Int{
        var secs = self
        while(secs >= 60){
            secs -= 60
        }
        return secs
    }
    
    func GetRemainingMinutes() -> Int{
        var mins = self/60
        while(mins >= 60){
            mins -= 60
        }
        return mins
    }
    
    func GetRemainingHours() -> Int{
        var hours = self/(60 * 60)
        while(hours >= 24){
            hours -= 24
        }
        return hours
    }
    
    func GetRemainingDays() -> Int{
        var days = self/(24 * 60 * 60)
        while(days >= 365){
            days -= 365
        }
        return days
    }
    
    func GetYears() -> Int{
        let years = self/(365 * 24 * 60 * 60)
        return years
    }
    
    func GetTimeStringMinAndSec() -> String{
        let formatter = DateFormatter()
        let gbDateFormat = DateFormatter.dateFormat(fromTemplate: "mmss", options: 0, locale: Locale(identifier: "en-GB"))
        formatter.dateFormat = gbDateFormat
        let date = Date(timeIntervalSinceReferenceDate: Double(self))
        return formatter.string(from: date)
    }
    
    func getUPnPTimeFormat() -> String{
        let hours = self / 3600
        let minutes = (self / 60) % 60
        let seconds = self % 60
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
}

extension String{
    func getIntFromTimeInterval() -> Int{
        let array = self.components(separatedBy: ":")
        let hours = Int(array[0])!
        let min = Int(array[1])!
        let sec = Int(array[2])!
        return (hours*60*60) + (min*60) + sec
    }
}
