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
        
        self.view.addSubview(mapView)
        self.view.addSubview(searchByCenterBtn)
        self.view.addSubview(infoView)
        self.view.addSubview(expectTimeLb)
        self.view.addSubview(myLocationBtn)
        
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


extension MaskMapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            updateMyLocation(lastLocation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        mapView.overlays.forEach {
            mapView.removeOverlay($0)
        }
        
        guard let annoCoord = view.annotation?.coordinate else { return }
        
        let startItem = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
        let endItem = MKMapItem(placemark: MKPlacemark(coordinate: annoCoord))
        
        let directionRequest = MKDirections.Request()
        
        directionRequest.source = startItem
        directionRequest.destination = endItem
        directionRequest.transportType = .walking
        
        let direction = MKDirections(request: directionRequest)
        
        
        direction.calculate { (res, err) in
            
            guard let res = res else { return }
            
            let route = res.routes[0]
            
            print(route.expectedTravelTime, "EXPCTED")
            
            self.expectedTime.onNext("도보 \(Int((route.expectedTravelTime / 60).rounded())) 분 거리")
            
            mapView.addOverlays([route.polyline], level: .aboveRoads)
            
            let rekt = route.polyline.boundingMapRect
            mapView.setRegion(MKCoordinateRegion(rekt), animated: true)
            
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let polylines = mapView.overlays(in: .aboveRoads).filter { $0 is MKPolyline } as! [MKPolyline]
        
        guard let line = polylines.first else { return MKOverlayRenderer() }
        
        let lineRenderer = MKPolylineRenderer(polyline: line)
        
        lineRenderer.strokeColor = .systemTeal
        lineRenderer.lineWidth = 5
        
        return lineRenderer
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation.isKind(of: MKUserLocation.self)) else { return nil }
        
        let annoV = MaskAnnoView(annotation: annotation, reuseIdentifier: "hi")
        
        annoV.canShowCallout = true
        annoV.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        annoV.backgroundColor = .white
        annoV.layer.cornerRadius = annoV.frame.width / 2
        
        
        if let anno = annotation as? MaskAnno {
            annoV.setColor(status: anno.maskStatus ?? "empty")
            return annoV
        } else {
            return nil
        }
    }
}

class MaskAnno: MKPointAnnotation {
    var maskStatus: String?
}

class MaskAnnoView: MKAnnotationView {
    
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
            //                .resizableImage(withCapInsets: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
            imgView.tintColor = .white
            imgView.contentMode = .scaleAspectFit
            
            switch status {
            case "plenty":
                self.backgroundColor = .limeGreen
            //                imgView.tintColor = .limeGreen
            case "some":
                self.backgroundColor = .overYellow
            //                imgView.tintColor = .overYellow
            case "few":
                self.backgroundColor = .red
            //                imgView.tintColor = .red
            case "empty":
                self.backgroundColor = .gray
            //                imgView.tintColor = .gray
            default:
                break
            }
        }
    }
    
    
}

class InfoView: UIView {
    
    let horiStackView = UIStackView()
    let closeBtn = UIButton()
    let alertLb = UILabel()
    let lastUpdateLb = UILabel()
    var isSelected = false
    let disposeBag = DisposeBag()
    
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
        
        
        self.addSubview(horiStackView)
        self.addSubview(closeBtn)
        self.addSubview(lastUpdateLb)
        self.addSubview(alertLb)
        
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

class MaskInfoView: UIView {
    
    let imgView = UIImageView()
    let lbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLayout() {
        self.addSubview(imgView)
        self.addSubview(lbl)
        
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


