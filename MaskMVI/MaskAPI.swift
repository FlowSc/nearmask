//
//  MaskAPI.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/12.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation
import Moya

enum MaskAPI {
    case getStoreByGeo(lat: String, lng: String, m: String)
}

extension MaskAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://8oi9s0nnth.apigw.ntruss.com/corona19-masks/v1")!
    }
    
    var path: String {
        switch self {
        case .getStoreByGeo:
            return "/storesByGeo/json"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getStoreByGeo(let lat, let lng, let m):
            return Task.requestParameters(parameters: ["lat":lat, "lng":lng, "m":m], encoding:  URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
