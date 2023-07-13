//
//  Global.swift
//  Cube
//
//  Created by 陈沈杰 on 2022/12/28.
//

import Foundation
import UIKit

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
let LanguageChange = NSNotification.Name("LanguageChange")
var StatusHeight : CGFloat {
    if #available(iOS 13.0, *) {
        let scence = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let manager = scence.statusBarManager
        return manager?.statusBarFrame.height ?? 0
    } else {
        // Fallback on earlier versions
        return UIApplication.shared.statusBarFrame.size.height
    }
   
}


let isIPhoneX:Bool = StatusHeight > 20
