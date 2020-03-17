//
//  MaskInfoView.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/17.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation
import UIKit

final class MaskInfoView: UIView {
    
    private let imgView = UIImageView()
    private let lbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        
        self.addSubViews([imgView, lbl])
        
        imgView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.centerX.equalToSuperview()
            make.size.equalTo(20)
        }
        lbl.snp.makeConstraints { (make) in
            make.top.equalTo(imgView.snp.bottom).offset(5)
            make.leading.equalTo(3)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-5)
        }
    }
    
    func setAttributes() {
        imgView.backgroundColor = .white
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 11)
        lbl.textColor = .black
        lbl.textAlignment = .center
    }
    
    func setColor(status: String) {
        
        let originalImage = UIImage(named: "mask")
        
        if let tinted = originalImage?.withRenderingMode(.alwaysTemplate) {
            
            imgView.image = tinted
            
            switch status {
            case "plenty":
                imgView.tintColor = .limeGreen
                lbl.text = "100개 이상"
            case "some":
                imgView.tintColor = .overYellow
                lbl.text = "30~99개"
            case "few":
                imgView.tintColor = .red
                lbl.text = "30개 미만"
            case "empty":
                imgView.tintColor = .gray
                lbl.text = "없음"
            default:
                break
            }
        }
    }
}


