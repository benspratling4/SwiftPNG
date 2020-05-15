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
		
	//	let path = Path(inRect:Rect(origin:.zero, size:Size(width: 50.0, height: 50.0)))
	//	context.fillPath(path, color:SampledColor(components:[[0x00], [0xFF], [0x00], [0xFF]]))
		
		var path3:Path = Path(subPaths: [])
			.byMoving(to: Point(x: 5.0, y: 45.0))
			.byAddingLine(to: Point(x: 15.0, y: 5.0))
			.byAddingLine(to: Point(x: 35.0, y: 5.0))
//			.byMoving(to:Point(x: 0.0, y: 25.0))
		path3.addCurve(near:Point(x: 50.0, y: 25.0)
			,and:Point(x: 50.0, y: 25.0)
			,to:Point(x: 35.0, y: 40.0))
		path3.close()
		context.drawPath(path3, fillShader: SolidColorShader(color: colorSpace.black), stroke: nil)
		
		
//		var path3:Path = Path(subPaths: [])
//			.byMoving(to:Point(x: 25.0, y: 0.0))
//		path3.addCurve(near:Point(x: 0.0, y: 25.0)
//			,and:Point(x: 50.0, y: 25.0)
//			,to:Point(x: 25.0, y: 50.0))
//		context.fillPath(path3, color:colorSpace.black)
		
		
//		var path3:Path = Path(subPaths: [])
//				.byMoving(to:Point(x: 0.0, y: 0.0))
//		path3.addCurve(near:Point(x: 50.0, y: 00.0)
//			,and:Point(x: 0.0, y: 50.0)
//			,to:Point(x: 50.0, y: 50.0))
//		context.fillPath(path3, color:colorSpace.black)

		guard let pngData = context.image.pngData else {
			XCTFail("couldn't get png data")
			return
		}
		let outputFilePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("bezier output test.png")
		try? pngData.write(to: outputFilePath)
	}
	
	
	func testBezierStroking() {
		let colorSpace:ColorSpace = GenericRGBAColorSpace(hasAlpha: true)
		let context = SampledGraphicsContext(dimensions: Size(width: 50.0, height: 50.0), colorSpace: colorSpace)
		context.antialiasing = .subsampling(resolution: .three)
		
		let path = Path(inRect:Rect(origin:.zero, size:Size(width: 50.0, height: 50.0)))
		context.drawPath(path, fillShader: SolidColorShader(color: SampledColor(components:[[0x00], [0xFF], [0x00], [0xFF]])), stroke: nil)
		
		var path3:Path = Path(subPaths: [])
			.byMoving(to:Point(x:10.0, y: 15.0))
		path3.addCurve(near: Point(x:25.0, y: 45.0), to: Point(x:40.0, y: 15.0))
	//	path3.addLine(to:Point(x:40.0, y: 25.0))
		context.drawPath(path3, fillShader: SolidColorShader(color:colorSpace.white), stroke: nil)
		context.drawPath(path3, fillShader:nil, stroke:(SolidColorShader(color:colorSpace.black), StrokeOptions(lineWidth:2.0)))
		
		guard let pngData = context.image.pngData else {
			XCTFail("couldn't get png data")
			return
		}
		let outputFilePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("bezier stroke output test.png")
		try? pngData.write(to: outputFilePath)
	}
	
	
	func testDrawLetterA() {
		let colorSpace:ColorSpace = GenericRGBAColorSpace(hasAlpha: true)
		let context = SampledGraphicsContext(dimensions: Size(width: 50.0, height: 50.0), colorSpace: colorSpace)
		context.antialiasing = .subsampling(resolution: .three)
		
		let path = Path(inRect:Rect(origin:.zero, size:Size(width: 50.0, height: 50.0)))
	//	context.fillPath(path, color:SampledColor(components:[[0xFF], [0xFF], [0xFF], [0xFF]]))
		
		var aPath = Path()
			.byMoving(to: Point(x: 6.53, y: 47.54))
			.byAddingLine(to: Point(x: 21.64, y: 3.26))
			.byAddingLine(to: Point(x: 28.47, y: 3.26))
			.byAddingLine(to: Point(x: 43.58, y: 47.54))
			.byAddingLine(to: Point(x: 37.47, y: 47.54))
			.byAddingLine(to: Point(x: 32.74, y: 33.61))
			.byAddingLine(to: Point(x: 17.04, y: 33.61))
			.byAddingLine(to: Point(x: 12.45, y: 47.54))
			.byAddingLine(to: Point(x: 6.53, y: 47.54))
			.byMoving(to: Point(x: 18.23, y: 29.14))
			.byAddingLine(to: Point(x: 24.93, y: 8.32))
			.byAddingLine(to: Point(x: 31.63, y: 29.14))
			.byAddingLine(to: Point(x: 18.23, y: 29.14))
		
		context.drawPath(aPath, fillShader: SolidColorShader(color:colorSpace.black), stroke: nil)
		
		guard let pngData = context.image.pngData else {
			XCTFail("couldn't get png data")
			return
		}
		let outputFilePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("test draw letter A.png")
		try? pngData.write(to: outputFilePath)
	}

	func testDrawLetterB() {
		//svg of B
		/*
		<!-- Generator: Adobe Illustrator 24.0.1, SVG Export Plug-In  -->
		<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="35.7px"
			 height="39.7px" viewBox="0 0 35.7 39.7" style="enable-background:new 0 0 35.7 39.7;" xml:space="preserve">
		<defs>
		</defs>
		<g>
			<path d="M26.7,19.5c2.8,0.6,4.8,1.5,6.2,2.8c1.9,1.8,2.8,4,2.8,6.6c0,2-0.6,3.9-1.9,5.7s-3,3.1-5.1,4s-5.5,1.2-10,1.2H0v-1.1h1.5
				c1.7,0,2.9-0.5,3.6-1.6c0.4-0.7,0.7-2.1,0.7-4.4V7c0-2.5-0.3-4-0.8-4.7C4.1,1.5,3,1.1,1.5,1.1H0V0h17.2c3.2,0,5.8,0.2,7.7,0.7
				c2.9,0.7,5.2,1.9,6.7,3.7s2.3,3.8,2.3,6.2c0,2-0.6,3.8-1.8,5.3C30.9,17.5,29.1,18.7,26.7,19.5z M11.4,17.9c0.7,0.1,1.5,0.2,2.5,0.3
				c0.9,0.1,1.9,0.1,3.1,0.1c2.9,0,5-0.3,6.4-0.9s2.5-1.6,3.3-2.8c0.8-1.3,1.1-2.7,1.1-4.2c0-2.3-0.9-4.3-2.8-5.9S20.3,2,16.6,2
				c-2,0-3.7,0.2-5.3,0.6V17.9z M11.4,36.9c2.3,0.5,4.5,0.8,6.7,0.8c3.5,0,6.2-0.8,8.1-2.4s2.8-3.6,2.8-5.9c0-1.5-0.4-3-1.3-4.5
				s-2.2-2.5-4.1-3.4s-4.2-1.2-7-1.2c-1.2,0-2.2,0-3.1,0.1c-0.9,0-1.6,0.1-2.1,0.2V36.9z"/>
		</g>
		</svg>

		
		*/
	}
	
	
	
}
