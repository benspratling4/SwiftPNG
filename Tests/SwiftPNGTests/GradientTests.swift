//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/14/20.
//

import Foundation
import XCTest
@testable import SwiftGraphicsCore
@testable import SwiftPNG



class GradientTests : XCTestCase {
	
	
	func testLinearGradient() {
		
		let colorSpace:ColorSpace = GenericRGBAColorSpace(hasAlpha: true)
			let context = SampledGraphicsContext(dimensions: Size(width: 50.0, height: 50.0), colorSpace: colorSpace)
			context.antialiasing = .subsampling(resolution: .three)
			
			let path = Path(inRect:Rect(origin:.zero, size:Size(width: 50.0, height: 50.0)))
		//	context.fillPath(path, color:SampledColor(components:[[0xFF], [0xFF], [0xFF], [0xFF]]))
			
			var aPath = Path()
//				.byMoving(to: Point(x: 6.53, y: 47.54))
//				.byAddingLine(to: Point(x: 21.64, y: 3.26))
//				.byAddingLine(to: Point(x: 28.47, y: 3.26))
//				.byAddingLine(to: Point(x: 43.58, y: 47.54))
//				.byAddingLine(to: Point(x: 37.47, y: 47.54))
//				.byAddingLine(to: Point(x: 32.74, y: 33.61))
//				.byAddingLine(to: Point(x: 17.04, y: 33.61))
//				.byAddingLine(to: Point(x: 12.45, y: 47.54))
//				.byAddingLine(to: Point(x: 6.53, y: 47.54))
//				.byMoving(to: Point(x: 18.23, y: 29.14))
//				.byAddingLine(to: Point(x: 24.93, y: 8.32))
//				.byAddingLine(to: Point(x: 31.63, y: 29.14))
//				.byAddingLine(to: Point(x: 18.23, y: 29.14))
				.byMoving(to: Point(x: 0.0, y: 0.0))
				.byAddingLine(to: Point(x: 50.0, y: 0.0))
				.byAddingLine(to: Point(x: 50.0, y: 50.0))
				.byAddingLine(to: Point(x: 0.0, y: 50.0))
				.byAddingLine(to: Point(x: 0.0, y: 0.0))
			
		let linearGradient = LinearGradient(start: Point(x: 10, y: 10), end: Point(x: 40, y: 40), stops: [
			GradientColorStop(position: 0.0, color:SampledColor(components: [[255],[0],[0],[255]])),
			GradientColorStop(position: 0.5, color:SampledColor(components: [[0],[255],[0],[255]])),
			GradientColorStop(position: 1.0, color:SampledColor(components: [[0],[0],[255],[255]]))
		], continuation: [.continuesAfter])
		
		
			context.drawPath(aPath, fillShader: linearGradient, stroke: nil)
			
			guard let pngData = context.image.pngData else {
				XCTFail("couldn't get png data")
				return
			}
			let outputFilePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("test draw letter A with gradient.png")
			try? pngData.write(to: outputFilePath)
		
		
	}
	
	

	func testRadialGradient() {
		
		let colorSpace:ColorSpace = GenericRGBAColorSpace(hasAlpha: true)
		let context = SampledGraphicsContext(dimensions: Size(width: 50.0, height: 50.0), colorSpace: colorSpace)
		context.antialiasing = .subsampling(resolution: .three)
		
		let path = Path(inRect:Rect(origin:.zero, size:Size(width: 50.0, height: 50.0)))
	//	context.fillPath(path, color:SampledColor(components:[[0xFF], [0xFF], [0xFF], [0xFF]]))
		
		var aPath = Path()
//			.byMoving(to: Point(x: 6.53, y: 47.54))
//			.byAddingLine(to: Point(x: 21.64, y: 3.26))
//			.byAddingLine(to: Point(x: 28.47, y: 3.26))
//			.byAddingLine(to: Point(x: 43.58, y: 47.54))
//			.byAddingLine(to: Point(x: 37.47, y: 47.54))
//			.byAddingLine(to: Point(x: 32.74, y: 33.61))
//			.byAddingLine(to: Point(x: 17.04, y: 33.61))
//			.byAddingLine(to: Point(x: 12.45, y: 47.54))
//			.byAddingLine(to: Point(x: 6.53, y: 47.54))
//			.byMoving(to: Point(x: 18.23, y: 29.14))
//			.byAddingLine(to: Point(x: 24.93, y: 8.32))
//			.byAddingLine(to: Point(x: 31.63, y: 29.14))
//			.byAddingLine(to: Point(x: 18.23, y: 29.14))
			.byMoving(to: Point(x: 0.0, y: 0.0))
			.byAddingLine(to: Point(x: 50.0, y: 0.0))
			.byAddingLine(to: Point(x: 50.0, y: 50.0))
			.byAddingLine(to: Point(x: 0.0, y: 50.0))
			.byAddingLine(to: Point(x: 0.0, y: 0.0))
		let radialGradient = RadialGradient(startCenter: Point(x:10.0, y: 25.0), startRadius: 20.0, endCenter: Point(x: 35.0, y: 25.0), endRadius: 10.0
			, stops: [
		GradientColorStop(position: 0.0, color:SampledColor(components: [[255],[0],[0],[255]])),
		GradientColorStop(position: 0.5, color:SampledColor(components: [[0],[255],[0],[255]])),
		GradientColorStop(position: 1.0, color:SampledColor(components: [[0],[0],[255],[255]]))
		], continuation: [])
		
		context.drawPath(aPath, fillShader:radialGradient, stroke: nil)
		
		guard let pngData = context.image.pngData else {
			XCTFail("couldn't get png data")
			return
		}
		let outputFilePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("radialGradientTest.png")
		try? pngData.write(to: outputFilePath)
	
	
	}
	
	
	
}
