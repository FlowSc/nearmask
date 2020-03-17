//
//  MaskNetwork.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/12.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxOptional
import RxCocoa


final class MaskNetwork {
    
    private let provider: MoyaProvider<MaskAPI>
    static let shared = MaskNetwork()
    
    private init() {
        self.provider = MoyaProvider<MaskAPI>()
    }
    
    func getStoreBy(lat: String, lng: String, m: String) -> Observable<Result<ApiResult, MaskError>> {
        
        return Observable.create { observer -> Disposable in
        
            self.provider.request(.getStoreByGeo(lat: lat, lng: lng, m: m)) { (response) in
                
                switch response.result {
                case .success(let res):
                    if let result = try? res.map(ApiResult.self) {
                        observer.onNext(.success(result))
                    } else {
                        observer.onNext(.failure(.defaultE))
                    }
                case .failure(let err):
                    observer.onNext(.failure(.err(err.errorDescription ?? "")))
                }
            }
        return Disposables.create()

            
        }
        
        
    }
    
    
}


enum MaskError: Error {
    case defaultE
    case err(String)
    
    var msg: String? {
        switch self {
        case .defaultE : return "Default Error"
        case .err(let msg): return msg
        }
    }
}
