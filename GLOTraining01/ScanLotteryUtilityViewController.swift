//
//  ScanLotteryUtilityViewController.swift
//  GLOTraining01
//
//  Created by Tanapong Borrirakwisitsak on 27/9/2562 BE.
//  Copyright © 2562 ClickNext. All rights reserved.
//

import UIKit

enum LocaleType : String {
	case th = "th_TH"
	case en = "en_EN"
	
}

extension ScanLotteryViewController {
	
	func convert(string:String, toDateWith format:String, isGregorian:Bool, locale:String) -> Date {
		
		let formatter = DateFormatter()
		if isGregorian == true {
			formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		}else{
			formatter.calendar = Calendar(identifier: Calendar.Identifier.buddhist)
		}
		formatter.dateFormat = format
		formatter.locale = Locale(identifier: locale)
		return formatter.date(from: string) ?? Date()
		
	}
	
	func convert(date:Date, toStringWith format:String, isGregorian:Bool, locale:String) -> String {
		let formatter = DateFormatter()
		if isGregorian == true {
			formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
		}else{
			formatter.calendar = Calendar(identifier: Calendar.Identifier.buddhist)
		}
		formatter.dateFormat = format
		let locale : Locale = Locale(identifier: locale)
		formatter.locale = locale
		
		return formatter.string(from: date)
		
	}
	
	func getLotteryData(lotteryScanData: String) -> (date: String, draw: String, set: String, lotteryNumber:String){
        let replaceString = lotteryScanData.replacingOccurrences(of: "-", with: " ")
        let datas = replaceString.components(separatedBy: " ")
        if datas.count >= 4 {
            let year = datas[0]
            let draw = datas[1]
            let set = datas[2]
            let lotteryNumber = datas[3]
            return (year, draw, set, lotteryNumber)
        }
        return ("", "", "", "")
    }
	
}
