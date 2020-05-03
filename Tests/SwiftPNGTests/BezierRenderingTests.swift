//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/3/20.
//

import Foundation
import XCTest
@testable import SwiftPNG
import SwiftGraphicsCore


class BezierRenderingTests : XCTestCase {
	
	func testBezierCurveDrawOnPngExport() {
		let colorSpace:ColorSpace = GenericRGBAColorSpace(hasAlpha: true)
		let context = SampledGraphicsContext(dimensions: Size(width: 50.0, height: 50.0), colorSpace: colorSpace)
		context.antialiasing = .subsampling(resolution: .three)
		
		let path = Path(inRect:Rect(origin:.zero, size:Size(width: 50.0, height: 50.0)))
		context.fillPath(path, color:SampledColor(components:[[0x00], [0xFF], [0x00], [0xFF]]))
		
		var path3:Path = Path(subPaths: [])
			.byMoving(to:Point(x: 0.0, y: 25.0))
		path3.addCurve(near:Point(x: 25.0, y: 50.0)
			,and:Point(x: 25.0, y: 0.0)
			,to:Point(x: 50.0, y: 25.0))
		context.fillPath(path3, color:colorSpace.black)

		
		guard let pngData = context.image.pngData else {
			XCTFail("couldn't get png data")
			return
		}
		let outputFilePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("bezier output test.png")
		try? pngData.write(to: outputFilePath)
	}

}
