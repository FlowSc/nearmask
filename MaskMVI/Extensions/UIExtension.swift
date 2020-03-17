//
//  UIExtension.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/13.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addSubViews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
    
}

extension UIImage {
    
    func render() -> UIImage {
        return self.withRenderingMode(.alwaysTemplate)
    }
    
}

extension UIColor {
    static var limeGreen: UIColor { UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 1) }
    static var overYellow: UIColor { UIColor(red: 250/255, green: 156/255, blue: 29/255, alpha: 1) }
}
