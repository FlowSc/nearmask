//
//  MaskAnnotationView.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/17.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation
import UIKit
import MapKit

final class MaskAnno: MKPointAnnotation {
    var maskStatus: String?
}

final class MaskAnnotationView: MKAnnotationView {
    
    private let imgView = UIImageView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    private func setUI() {
        self.addSubview(imgView)
        
        imgView.snp.makeConstraints { (make) in
            make.top.leading.equalTo(3)
            make.bottom.trailing.equalTo(-3)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(status: String) {
        
        let originalImage = UIImage(named: "mask")
        
        if let tinted = originalImage?.withRenderingMode(.alwaysTemplate) {
            
            imgView.image = tinted
            imgView.tintColor = .white
            imgView.contentMode = .scaleAspectFit
            
            switch status {
            case "plenty":
                self.backgroundColor = .limeGreen
            case "some":
                self.backgroundColor = .overYellow
            case "few":
                self.backgroundColor = .red
            case "empty":
                self.backgroundColor = .gray
            default:
                break
            }
        }
    }
}

