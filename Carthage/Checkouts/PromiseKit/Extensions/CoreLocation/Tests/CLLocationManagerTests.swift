import PMKCoreLocation
import CoreLocation
import PromiseKit
import XCTest

#if !os(tvOS)

class Test_CLLocationManager_Swift: XCTestCase {
    func test_fulfills_with_multiple_locations() {
        swizzle(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocation)) {
            let ex = expectation(description: "")

            CLLocationManager.promise().done { x in
                XCTAssertEqual(x, dummy)
                ex.fulfill()
            }

            waitForExpectations(timeout: 1, handler: nil)
        }
    }

#if os(iOS)
    func test_requestAuthorization() {
        let ex = expectation(description: "")

        CLLocationManager.requestAuthorization().done {
            XCTAssertEqual($0, CLAuthorizationStatus.restricted)
            ex.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
#endif
}


/////////////////////////////////////////////////////////////// resources
private let dummy = [CLLocation(latitude: 0, longitude: 0), CLLocation(latitude: 10, longitude: 20)]

extension CLLocationManager {
    @objc func pmk_startUpdatingLocation() {
        after(.milliseconds(100)).done {
            self.delegate!.locationManager?(self, didUpdateLocations: dummy)
        }
    }
}


/////////////////////////////////////////////////////////////// utilities
import ObjectiveC

func swizzle(_ foo: AnyClass, _ from: Selector, isClassMethod: Bool = false, body: () -> Void) {
    let originalMethod: Method
    let swizzledMethod: Method

    if isClassMethod {
        originalMethod = class_getClassMethod(foo, from)
        swizzledMethod = class_getClassMethod(foo, Selector("pmk_\(from)"))
    } else {
        originalMethod = class_getInstanceMethod(foo, from)
        swizzledMethod = class_getInstanceMethod(foo, Selector("pmk_\(from)"))
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
    body()
    method_exchangeImplementations(swizzledMethod, originalMethod)
}

#endif
