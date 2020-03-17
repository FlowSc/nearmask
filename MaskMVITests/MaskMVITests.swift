//
//  MaskMVITests.swift
//  MaskMVITests
//
//  Created by Kang Seongchan on 2020/03/17.
//  Copyright © 2020 HanryangChan. All rights reserved.
//

import XCTest
@testable import MaskMVI
@testable import RxSwift
@testable import RxCocoa
@testable import RxTest
@testable import RxBlocking
@testable import RxOptional


class MaskMVITests: XCTestCase {

    var intent: MaskMapViewIntent!
    var network: MaskNetwork!
    
    override func setUp() {
        
        self.intent = MaskMapViewIntent()
        self.network = MaskNetwork.shared
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        
        let observableTest = Observable.of(10, 20, 30)
        
        do {
            let result = try observableTest.toBlocking().first()
            XCTAssertEqual(result, 10)
        } catch {
            
        }
    }
    
    func testNetwork() {
        
        do {
            
            let result = network.getStoreBy(lat: "37.49", lng: "127.02", m: "1500")
            let val = result.map { res -> ApiResult? in
                guard case .success(let value) = res else {
                    return nil }
                return value
            }.filterNil()

            let ree = try val.toBlocking().first()
            
            XCTAssert((ree?.stores.isNotEmpty)!)

            
        } catch {
            XCTFail()
        }

    }
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
