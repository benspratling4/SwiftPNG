//
//  TestBundleFileFinder.swift
//  SwiftPNGPackageDescription
//
//  Created by Ben Spratling on 10/28/17.
//

import Foundation



class TestBundleFileFinder {
	
	class func fileInTestSource(named:String, withExtension:String)->URL {
		#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
			let bundle:Bundle = Bundle(for:TestBundleFileFinder.self)
			if let zipURL = bundle.url(forResource: named, withExtension: withExtension) {
				return zipURL
			}
		#endif
		let path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
		return path.appendingPathComponent("Tests").appendingPathComponent("SwiftPNGTests").appendingPathComponent(named + "." + withExtension)
	}
	
	
}
