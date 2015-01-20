import Cocoa
import XCTest

public extension AXUIElement {
  public func getAttribute<T>(property: String) -> T? {
    var ptr: Unmanaged<AnyObject>?
    if AXUIElementCopyAttributeValue(self, property, &ptr) != AXError(kAXErrorSuccess) {
      return nil
    }
    return ptr.map {
      $0.takeRetainedValue() as T
    }
  }
}

enum AXAttributes: String {
  case Description = "AXDescription", Role = "AXRole", Windows = "AXWindows"
}

class Auto_StoreTests: XCTestCase {

  // https://github.com/sdegutis/DIY-Window-Manager/blob/master/Desktop/Desktop/App.swift
  func testRunningApplication() {
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

  func attributeValue(element: AXUIElement, attribute: AXAttributes) -> String? {
    var ptr: Unmanaged<AnyObject>?
    if AXUIElementCopyAttributeValue(element, attribute.rawValue, &ptr) != AXError(kAXErrorSuccess) {
      return nil
    }
    return ptr?.takeRetainedValue() as? String
  }

  func findWindowByName(name: String) -> AXUIElement? {
    for win in windows() {
      let name = win[kCGWindowOwnerName as NSString]
      if name as NSString == "App Store" {
        let pidi = win[kCGWindowOwnerPID as NSString] as NSInteger
        let pid: pid_t = Int32(pidi)
        return AXUIElementCreateApplication(pid).takeUnretainedValue()
      }
    }
    return nil
  }
  
  func testExample() {
    for win in openWindows() {
      let name = win[kCGWindowOwnerName as NSString]
      if name as NSString == "App Store" {
        let pidi = win[kCGWindowOwnerPID as NSString] as NSInteger
        let pid: pid_t = Int32(pidi)
        let app = AXUIElementCreateApplication(pid).takeUnretainedValue()
        var ptr: Unmanaged<AnyObject>?
        AXAttributes.Windows.rawValue
        AXUIElementCopyAttributeValue(app, AXAttributes.Windows.rawValue, &ptr)
        let windowList: AnyObject? = ptr?.takeRetainedValue()
        println(windowList)
        println(CFArrayGetCount(windowList as CFArray))
        let windowRef = CFArrayGetValueAtIndex(windowList as CFArray, 0)
        println(windowRef)
        AXUIElementCopyAttributeValue(app, "AXMainWindow", &ptr)
        let element = ptr?.takeRetainedValue() as AXUIElementRef
        let description = CFCopyTypeIDDescription(CFGetTypeID(element))
        println("type = \(description)")
        println(element)
        println(self.attributeValue(element, attribute: .Role))
        println(self.attributeValue(element, attribute: .Description))
      }
    }
  }
  
  // http://stackoverflow.com/a/24094636
  func openWindows() -> NSArray {
    return CGWindowListCopyWindowInfo(CGWindowListOption(kCGWindowListOptionOnScreenOnly), CGWindowID(0)).takeRetainedValue()
  }

}
