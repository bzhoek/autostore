#import <Foundation/Foundation.h>

NSArray *windows() {
  CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
  return CFBridgingRelease(windowList);
}

void bla(AXUIElementRef appRef) {
  CFArrayRef windowList;
  AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute, (CFTypeRef *) &windowList);
  NSLog(@"WindowList = %@", windowList);
}