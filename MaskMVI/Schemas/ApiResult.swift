//
//  ApiResult.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/12.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation

struct ApiResult: Codable {
    
    
    let count: Int
    let stores: [StoreSale]
    
}
