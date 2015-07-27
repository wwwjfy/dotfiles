#include <Carbon/Carbon.h>

int main(int argc, char **argv) {
  if (argc != 2) {
    printf("Usage: %s <window name>\n", argv[0]);
    printf("Exit code 0 indicates window with specified name is found");
    return 1;
  }

  CFArrayRef windowsInSpace = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);

  for (int i = 0; i < CFArrayGetCount(windowsInSpace); i++) {
    NSMutableDictionary *window = (NSMutableDictionary*)CFArrayGetValueAtIndex(windowsInSpace, i);
    NSString *windowName = (NSString *)[window objectForKey:@"kCGWindowName"];
    if ([windowName length]) {
      NSRange result = [windowName rangeOfString:@(argv[1])];
      if (result.location != NSNotFound) {
        return 0;
      }
    }
  }
  return 1;
}
