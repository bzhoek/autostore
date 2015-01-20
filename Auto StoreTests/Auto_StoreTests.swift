import Cocoa
import XCTest

class Auto_StoreTests: XCTestCase {

  // https://github.com/sdegutis/DIY-Window-Manager/blob/master/Desktop/Desktop/App.swift
  func testRuanningApplication() {
    let appstore: NSRunningApplication? = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.apple.appstore").first as? NSRunningApplication
    let pid = appstore?.processIdentifier
    let app = AXUIElementCreateApplication(pid!).takeRetainedValue()
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
