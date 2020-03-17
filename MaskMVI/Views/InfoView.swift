//
//  InfoView.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/17.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


final class InfoView: UIView {
    
    private let horiStackView = UIStackView()
    private let closeBtn = UIButton()
    private let alertLb = UILabel()
    private let lastUpdateLb = UILabel()
    private var isSelected = false
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        
        horiStackView.axis = .horizontal
        horiStackView.distribution = .fillEqually
        
        ["plenty", "some", "few", "empty"].forEach {
            let maskInfoV = MaskInfoView()
            maskInfoV.setColor(status: $0)
            horiStackView.addArrangedSubview(maskInfoV)
        }

        self.addSubViews([horiStackView, closeBtn, lastUpdateLb, alertLb])

        horiStackView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.leading.trailing.equalToSuperview()
        }
        
        alertLb.snp.makeConstraints { (make) in
            make.top.equalTo(horiStackView.snp.bottom).offset(5)
            make.leading.equalTo(5)
            make.centerX.equalToSuperview()
        }
        
        lastUpdateLb.snp.makeConstraints { (make) in
            make.bottom.equalTo(-10)
            make.top.equalTo(alertLb.snp.bottom).offset(5)
            make.leading.equalTo(5)
            make.centerX.equalToSuperview()
        }
        
        
        closeBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        closeBtn.rx.tap.bind {
            self.isSelected = !(self.isSelected)
            if !(self.isSelected) {
                self.alpha = 0.9
            } else {
                self.alpha = 0.2
            }
            
        }.disposed(by: disposeBag)
        
        self.alpha = 0.9
        
    }
    
    func setAttributes() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        
        alertLb.font = UIFont.systemFont(ofSize: 12)
        alertLb.textColor = .red
        alertLb.textAlignment = .center
        alertLb.numberOfLines = 0
        
        lastUpdateLb.font = UIFont.systemFont(ofSize: 10)
        lastUpdateLb.textColor = .gray
        lastUpdateLb.textAlignment = .center
        lastUpdateLb.numberOfLines = 0
        alertLb.text =  "현재 실제 수치와 재고 수량이 맞지 않습니다.\n참고용으로만 확인 부탁드립니다."
        
    }
    
    func setLastUpdateTime(_ date: String) {
        
        self.lastUpdateLb.text = "업데이트 시각: \(date)"
    }
    
    
}

