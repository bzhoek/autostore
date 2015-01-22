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
  case Children = "AXChildren", Description = "AXDescription", Role = "AXRole", Windows = "AXWindows"
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

  func attributeStringValue(element: AXUIElement, attribute: AXAttributes) -> String? {
    var ptr: Unmanaged<AnyObject>?
    if AXUIElementCopyAttributeValue(element, attribute.rawValue, &ptr) != AXError(kAXErrorSuccess) {
      return nil
    }
    return ptr?.takeRetainedValue() as? String
  }

  func attributeValue(element: AXUIElement, attribute: AXAttributes) -> AnyObject? {
    var ptr: Unmanaged<AnyObject>?
    if AXUIElementCopyAttributeValue(element, attribute.rawValue, &ptr) != AXError(kAXErrorSuccess) {
      return nil
    }
    return ptr?.takeRetainedValue()
  }

  func attributeValue<T>(element: AXUIElement, attribute: AXAttributes) -> T? {
    var ptr: Unmanaged<AnyObject>?
    if AXUIElementCopyAttributeValue(element, attribute.rawValue, &ptr) != AXError(kAXErrorSuccess) {
      return nil
    }
    return ptr?.takeRetainedValue() as? T
  }

  // http://stackoverflow.com/a/24094636
  func openWindows() -> NSArray {
    return CGWindowListCopyWindowInfo(CGWindowListOption(kCGWindowListOptionOnScreenOnly), CGWindowID(0)).takeRetainedValue()
  }

  func findWindowByName(name: String) -> AXUIElement? {
    for window in openWindows() {
      if window[kCGWindowOwnerName as NSString] as NSString == name {
        let pid: pid_t = Int32(window[kCGWindowOwnerPID as NSString] as NSInteger)
        return AXUIElementCreateApplication(pid).takeUnretainedValue()
      }
    }
    return nil
  }

  // https://blog.codecentric.de/en/2014/10/extending-xctestcase-testing-swift-optionals/
  func XCTAssertEqualOptional<T:Equatable>(actual: @autoclosure () -> T?, _ expected: @autoclosure () -> T, file: String = __FILE__, line: UInt = __LINE__) {
    if let actual = actual() {
      let expected = expected()
      if actual != expected {
        self.recordFailureWithDescription("Optional(\(actual)) is not equal to (\(expected))", inFile: file, atLine: line, expected: true)
      }
    } else {
      self.recordFailureWithDescription("Optional value is empty", inFile: file, atLine: line, expected: true)
    }
  }

  func testAppStore() {
    if let app = findWindowByName("App Store") {
      var ptr: Unmanaged<AnyObject>?
      AXUIElementCopyAttributeValue(app, AXAttributes.Windows.rawValue, &ptr)
      let windowList: AnyObject? = ptr?.takeRetainedValue()
      println(windowList)
      println(CFArrayGetCount(windowList as CFArray))
      let windowRef = CFArrayGetValueAtIndex(windowList as CFArray, 0)
      println(windowRef)
      AXUIElementCopyAttributeValue(app, "AXMainWindow", &ptr)
      let element = ptr?.takeRetainedValue() as AXUIElementRef
      println("type = \(CFCopyTypeIDDescription(CFGetTypeID(element)))")
      println(element)
      XCTAssertEqualOptional(self.attributeValue(element, attribute: .Role), "AXWindow")
      XCTAssertEqualOptional(self.attributeValue(element, attribute: .Description), "App Store")
      if let children: NSArray = self.attributeValue(element, attribute: .Children) {
        for child in children {
          println("type = \(CFCopyTypeIDDescription(CFGetTypeID(child)))")
          var names: Unmanaged<CFArray>? = nil
          AXUIElementCopyAttributeNames(child as AXUIElement, &names)
          println(names?.takeRetainedValue())
          println(self.attributeValue(child as AXUIElementRef, attribute: .Role) as String)
        }
      }
//      for  {
//        XCTAssertEqualOptional(child.attributeValue(element, attribute: .Description), "App Store")
//      }
//      println(children)
    } else {
      XCTFail("App Store not found")
    }
  }

}
