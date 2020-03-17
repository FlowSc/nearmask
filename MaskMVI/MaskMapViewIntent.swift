//
//  MaskMapViewIntent.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/12.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import MapKit

protocol MaskViewState {}

struct MaskResult: MaskViewState {
    let r: ApiResult
}

struct ErrorResult: MaskViewState {
    let e: MaskError
}

class MaskMapViewIntent {
    
    private var vc: MaskMapViewController?
    private let stateObserver = PublishRelay<MaskViewState>()
    private let network = MaskNetwork.shared
    private let disposeBag = DisposeBag()
    
    func bindTo(_ vc: MaskMapViewController) {
        
        self.vc = vc
        
        stateObserver.subscribe(onNext: { (state) in
            self.vc?.update(state: state)
        }).disposed(by: disposeBag)
    }
    
    func loadResult(lat: String, lng: String, m: String) {
        
        let result = network.getStoreBy(lat: lat, lng: lng, m: m).share()
        
        let success = result.map {
            result -> ApiResult? in
            guard case .success(let value) = result else { return nil }
            return value
        }.filterNil()
        
        
        let failure = result.map {
            result -> MaskError? in
            guard case .failure(let err) = result else { return nil }
            return err
        }.filterNil()
        
        success.subscribe(onNext: { (r) in
            print(r)
            self.stateObserver.accept(MaskResult(r: r))
        }).disposed(by: disposeBag)
        
        
        failure.subscribe(onNext: { (e) in
            self.stateObserver.accept(ErrorResult(e: e))
        }).disposed(by: disposeBag)
    }
    
    func moveToMyLocation(_ my: CLLocationCoordinate2D) {
        vc?.mapView.setRegion(MKCoordinateRegion(center: my, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
    }
    
    func moveToSetting() {
        guard let settingsUrl = URL(string: (UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!)) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
}
