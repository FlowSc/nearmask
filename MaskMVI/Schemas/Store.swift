//
//  Store.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/12.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation

struct Store: Codable {
    
    let code: String
    let name: String
    let addr: String
    let type: String
    let lat: Double
    let lng: Double
    
}
