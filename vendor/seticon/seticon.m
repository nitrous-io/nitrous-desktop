#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    if (argc != 3) {
      fprintf(stderr, "Nitrous Desktop SetIcon\nUsage: seticon <icon> <file>\n");
      return 1;
    }

    NSString *iconPath = [NSString stringWithUTF8String:argv[1]];
    NSString *filePath = [NSString stringWithUTF8String:argv[2]];

    NSImage *icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
    if (!icon) {
      fprintf(stderr, "seticon: failed to load icon\n");
      return 1;
    }

    if (![[NSWorkspace sharedWorkspace] setIcon:icon forFile:filePath options:0]) {
      fprintf(stderr, "seticon: failed to set icon\n");
      return 1;
    }
  }
  return 0;
}
