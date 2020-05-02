//
//  DecompressionTests.swift
//  SwiftPNGTests
//
//  Created by Ben Spratling on 10/29/17.
//

import XCTest
import CoreGraphics
import AppKit

@testable import SwiftPNG

class DecompressionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	
	func testDecompression() {
		let realDataUrl:URL = TestBundleFileFinder.fileInTestSource(named: "smallpng", withExtension: "png")
		guard let smallPngData = try? Data(contentsOf: realDataUrl)
			else {
				XCTFail("didn't find real png file to test")
				return
		}
		
		guard let file = try? PNGFile(serializedData: smallPngData) else {
			XCTFail("unable to interpret file")
			return
		}
		print(file.header)
		
		let unfiltered = file.imageData()
		let provider = CGDataProvider(data: unfiltered as CFData)!
		let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
		
		let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear)!
		let cgimage = CGImage(width: Int(file.header.width), height: Int(file.header.height), bitsPerComponent: Int(file.header.bitDepth), bitsPerPixel: 32, bytesPerRow: Int(file.header.width) * 4, space: colorSpace, bitmapInfo: info, provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)!
		let nsImage =  NSImage(cgImage: cgimage, size: NSSize(width: CGFloat(file.header.width), height: CGFloat(file.header.height)))
		print(nsImage)
		print(unfiltered)
		
		file.preIDATChunks = []
		file.postIDATChunks = []
		file.prePalletChunks = []
		let basicData = file.serialize()
		try? basicData.write(to: URL(fileURLWithPath: "/Users/ben/GitHub/SwiftPNG/basic.png"))
		

	}
	

}
