//
//  MaskMapViewController.swift
//  MaskMVI
//
//  Created by Kang Seongchan on 2020/03/12.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxAppState
import MapKit

class MaskMapViewController: UIViewController {
    
    let mapView = MKMapView()
    let disposeBag = DisposeBag()
    let intent = MaskMapViewIntent()
    let searchBtn = UIButton()
    let searchByCenterBtn = UIButton()
    let locationManager = CLLocationManager()
    let infoView = InfoView()
    let myLocationBtn = UIButton()
    let expectTimeLb = UILabel()
    
    var expectedTime = PublishSubject<String?>()
    
    var myLocation = PublishSubject<CLLocationCoordinate2D>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocation()
        setUI()
        intent.bindTo(self)
        bindTo(intent)
        
    }
    
    func setLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            mapView.delegate = self
        }
        
    }
    
    
    func bindTo(_ intent: MaskMapViewIntent) {
        
        searchByCenterBtn.rx.tap.bind {
            let center = self.mapView.centerCoordinate
            intent.loadResult(lat: "\(center.latitude)", lng: "\(center.longitude)", m: "1500")
        }.disposed(by: disposeBag)
        
        Observable.combineLatest(self.rx.viewWillAppear, myLocation).flatMapLatest { (result) -> Observable<CLLocationCoordinate2D> in
            return Observable.of(result.1)
        }.single().subscribe(onNext: { (d2) in
            intent.loadResult(lat: "\(d2.latitude)", lng: "\(d2.longitude)", m: "1500")
        }).disposed(by: disposeBag)
        
        
        myLocationBtn.rx.tap.withLatestFrom(myLocation).bind {
            intent.moveToMyLocation($0)
        }.disposed(by: disposeBag)
        
        expectedTime.bind {
            self.expectTimeLb.text = $0
        }.disposed(by: disposeBag)
        
    }
    
    private func setUI() {
        
        self.view.addSubViews([mapView, searchByCenterBtn, infoView, expectTimeLb, myLocationBtn])
        
        mapView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        searchByCenterBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-50)
            make.width.equalTo(160)
            make.height.equalTo(40)
        }
        
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.leading.equalTo(20)
        }
        
        expectTimeLb.snp.makeConstraints { (make) in
            make.bottom.equalTo(searchByCenterBtn.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        myLocationBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchByCenterBtn.snp.centerY)
            make.trailing.equalTo(-20)
            make.size.equalTo(50)
        }
        
        
        searchByCenterBtn.setTitle("이 지역에서 검색", for: .normal)
        searchByCenterBtn.setTitleColor(.black, for: .normal)
        searchByCenterBtn.titleLabel?.font = .systemFont(ofSize: 14)
        expectTimeLb.font = .systemFont(ofSize: 14)
        //        expectTimeLb.textColor = .system
        searchByCenterBtn.setImage(UIImage(named: "baseline_search_black_18dp"), for: .normal)
        searchByCenterBtn.layer.cornerRadius = 10
        searchByCenterBtn.layer.borderWidth = 0.5
        searchByCenterBtn.layer.borderColor = UIColor.black.cgColor
        searchByCenterBtn.backgroundColor = .white
        
        myLocationBtn.setImage(UIImage(named: "baseline_my_location_black_18dp")?.render(), for: .normal)
        
    }
    
    func update(state: MaskViewState) {
        
        switch state {
        case is MaskResult:
            let result = state as! MaskResult
            
            addAnnoations(stores: result.r.stores.filter { $0.remain_stat != "break" })
            let last = result.r.stores.filter { $0.created_at != nil }
            if let ll = last.first {
                infoView.setLastUpdateTime(ll.created_at ?? "")
            }
        case is ErrorResult:
            let result = state as! ErrorResult
            print(result.e.msg ?? "")
        default:
            break
        }
    }
    
    func addAnnoations(stores: [StoreSale]) {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        let annos = stores.map { store -> MaskAnno in
            
            let anno = MaskAnno()
            anno.coordinate = CLLocationCoordinate2DMake(store.lat, store.lng)
            anno.title = store.name
            anno.subtitle = "입고시간: \(store.stock_at ?? "")"
            anno.maskStatus = store.remain_stat
            
            return anno
        }
        
        mapView.addAnnotations(annos)
        
    }
    
    func updateMyLocation(_ location: CLLocation) {
        
        myLocation.onNext(location.coordinate)
        locationManager.stopUpdatingLocation()
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
        
    }
    
}
