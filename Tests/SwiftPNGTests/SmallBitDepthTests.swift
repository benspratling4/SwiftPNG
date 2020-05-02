//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/2/20.
//

import Foundation
import XCTest
@testable import SwiftPNG
import SwiftSampledGraphics


class SmallBitDepthTests : XCTestCase {
	
	func testData(named:String)->Data {
		return try! Data(contentsOf:  URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent(named))
	}
	
	func writeTestOutput(_ data:Data, named:String) {
		try! data.write(to: URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent(named))
	}
	
	
	func test1BitPlain() {
		let names = [
					"spectrumTest1BitPlain",
//					 "spectrumTest1BitInter",
					 "spectrumTest4BitsPlain",
//					 "spectrumTest8ColorsInter",
//					 "spectrumTest32ColorsInter",
					 "spectrumTest32ColorsPlain",
//					 "spectrumTest64ColorsInter",
					 "spectrumTest64ColorsPlain",
//					 "spectrumTest128ColorsInter",
					 "spectrumTest128ColorsPlain",
//					 "spectrumTest256ColorsInter",
					 "spectrumTest256ColorsPlain",
		]
		for name in names {
			let data = testData(named: name + ".png")
			let image = try! SampledImage(pngData: data)
			guard let pngData = image.pngData else {
				XCTFail("couldn't read \(name)")
				return
			}
			//write out the data as a regular file
			writeTestOutput(pngData, named:name + "Output.png")
		}
	}
	
	
	
	
	func testOpeningTransparencyFiles() {
		let names:[String] = [
//		"spectrumTestTransTrueColorInter",
		"spectrumTestTransTrueColorPlain",
//		"spectrumTestTrans256ColorsInter",
		"spectrumTestTrans256ColorsPlain",
//		"spectrumTestTrans128ColorsInter",
		"spectrumTestTrans128ColorsPlain",
//		"spectrumTestTrans64ColorsInter",
		"spectrumTestTrans64ColorsPlain",
//		"spectrumTestTrans32ColorsInter",
		"spectrumTestTrans32ColorsPlain",
//		"spectrumTestTrans16ColorsInter",
		"spectrumTestTrans16ColorsPlain",
//		"spectrumTestTrans8ColorsInter",
		"spectrumTestTrans8ColorsPlain",
//		"spectrumTestTrans4ColorsInter",
		"spectrumTestTrans4ColorsPlain",
//		"spectrumTestTrans2ColorsInter",
		"spectrumTestTrans2ColorsPlain",
		]
		for name in names {
			let data = testData(named: name + ".png")
			let image = try! SampledImage(pngData: data)
			guard let pngData = image.pngData else {
				XCTFail("couldn't read \(name)")
				return
			}
			//write out the data as a regular file
			writeTestOutput(pngData, named:name + "Output.png")
		}
		
	}
	
}


