import Foundation

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("CaltrainMenuBar_CaltrainMenuBar.bundle").path
        let buildPath = "/Volumes/workplace/personal/railtimeMacOsWidget/.build/arm64-apple-macosx/debug/CaltrainMenuBar_CaltrainMenuBar.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            // Users can write a function called fatalError themselves, we should be resilient against that.
            Swift.fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}