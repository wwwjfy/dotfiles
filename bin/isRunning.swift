import AppKit

if Process.arguments.count < 2 {
    print("Usage: \(Process.arguments[0]) [bundle identifier]")
    exit(0)
}
if (NSRunningApplication.runningApplicationsWithBundleIdentifier(Process.arguments[1]).count > 0) {
    print("Running")
} else {
    print("Not Running")
}
