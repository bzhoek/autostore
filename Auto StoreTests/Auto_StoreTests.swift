//
//  Auto_StoreTests.swift
//  Auto StoreTests
//
//  Created by Bas van der Hoek on 18/01/15.
//  Copyright (c) 2015 Bas van der Hoek. All rights reserved.
//

import Cocoa
import XCTest

class Auto_StoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // https://github.com/sdegutis/DIY-Window-Manager/blob/master/Desktop/Desktop/App.swift
    func testExample() {
        let appstore: NSRunningApplication? = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.apple.appstore").first as? NSRunningApplication
        let pid = appstore?.processIdentifier
        let app = AXUIElementCreateApplication(pid!).takeRetainedValue()

        println(app)
//        println(appstore?.accessibilityActionNames())
//        println(appstore.accessibilityChildren())
    }
    
    // http://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
    // https://github.com/joelteon/Maxxxro/blob/master/Maxxxro/AppDelegate.swift
    func testAccessibilityEnabled() {
        let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let privOptions = [trusted as NSString: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(privOptions)
        XCTAssert(accessEnabled == 1, "Accessibility for Xcode not enabled")
    }
    
}
