//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import MetalKit

// This is a workaround to load metal shaders from Kanvas bundle.
// 1. Read .metal files from Kanvas.bundle/MetalShaders/ directory
// 2. Concatinate all source files as a string then compile it at runtime by using MTLDevice::makeLibrary(source:options:)
extension MTLDevice {
    public func makeKanvasDefaultLibrary() -> MTLLibrary? {
        let frameworkBundle = Bundle(for: CameraController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("Kanvas.bundle")
            
        let path = bundleURL?.path ?? ""
        let bundle = Bundle(url: bundleURL!)
        let shaderDirectoryPath = "\(bundleURL)/MetalShaders"
        let bundlePath = bundle?.bundlePath ?? ""
        print(path)
        print(shaderDirectoryPath)
        print(bundle)
        print(bundlePath)

        let enumerator = FileManager.default.enumerator(atPath: bundlePath)
        var source = ""
        while let filename = enumerator?.nextObject() as? String {
            if filename.hasSuffix("metal") {
                let fileURL = "\(shaderDirectoryPath)/\(filename)"
                
                do {
                    source += try String(contentsOfFile: fileURL, encoding: .utf8)
                }
                catch {
                    print("failed to read \(filename)")
                }
            }
        }
        
        do {
            let library = try makeLibrary(source: source, options: nil)
            return library
        }
        catch {
            print("\(error)")
            return nil
        }
    }
}
