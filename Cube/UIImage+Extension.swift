//
//  UIImage+Extension.swift
//  Cube
//
//  Created by 陈沈杰 on 2023/1/28.
//

import Foundation
import UIKit

func getFullColor(color:UIColor) -> UIImage?{
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    guard let context = UIGraphicsGetCurrentContext() else {
        print(" UIGraphicsGetCurrentContext 不存在")
        UIGraphicsEndImageContext()
        return nil
    }
    context.setFillColor(color.cgColor)
    context.fill(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img
}
