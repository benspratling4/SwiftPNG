//
//  PNGFormatVerificationTests.swift
//  SwiftPNGTests
//
//  Created by Ben Spratling on 10/28/17.
//

import XCTest

@testable import SwiftPNG

class PNGFormatVerificationTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testValidSignature() {
		let goodData:Data = Data([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
		XCTAssertTrue(goodData.isPNGFormat)
		
		let realDataUrl:URL = TestBundleFileFinder.fileInTestSource(named: "smallpng", withExtension: "png")
		guard let smallPngData = try? Data(contentsOf: realDataUrl)
			else {
			XCTFail("didn't find real png file to test")
			return
		}
		
		XCTAssertTrue(smallPngData.isPNGFormat)
	}
	
	func testValidChunks() {
		let realDataUrl:URL = TestBundleFileFinder.fileInTestSource(named: "smallpng", withExtension: "png")
		guard let smallPngData = try? Data(contentsOf: realDataUrl)
			else {
				XCTFail("didn't find real png file to test")
				return
		}
		let factory = ChunkInfoFactory(data:smallPngData)
		let allChunks = factory.allChunks
		print(allChunks.map({return $0.codeAsString ?? "????"}))
		XCTAssertTrue(ChunkInfoFactory.isChunkSequenceValid(allChunks))
	}
	
	func testImageHeaderChunk() {
		let realDataUrl:URL = TestBundleFileFinder.fileInTestSource(named: "smallpng", withExtension: "png")
		guard let smallPngData = try? Data(contentsOf: realDataUrl)
			else {
				XCTFail("didn't find real png file to test")
				return
		}
		let factory = ChunkInfoFactory(data:smallPngData)
		guard let imageHeader = factory.imageHeader else {
			XCTFail("no image header chunk found")
			return
		}
		print(imageHeader)
	}
	

	func testInvalidSignature() {
		let smallData:Data = Data([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08])
		XCTAssertFalse(smallData.isPNGFormat)
		
		let noHighBitData:Data = Data([0x09, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
		XCTAssertFalse(noHighBitData.isPNGFormat)
		
		let notPNGData:Data = Data([0x89, 0x00, 0x00, 0x00, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
		XCTAssertFalse(notPNGData.isPNGFormat)
		
		let dosLineEnding:Data = Data([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
		XCTAssertFalse(dosLineEnding.isPNGFormat)
		
		let dosTypeTruncation:Data = Data([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
		XCTAssertFalse(dosTypeTruncation.isPNGFormat)
		
	}
	

	static let allTests = [
		("testValidSignature", testValidSignature),
		("testInvalidSignature", testInvalidSignature),
	]
}
