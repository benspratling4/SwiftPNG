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



class TransformTests : XCTestCase {
	
	
	func testPointRotation() {
		let transform = Transform2D(rotation: .pi/2)
		XCTAssertEqual(transform.a, 0, accuracy:0.00000001)
		XCTAssertEqual(transform.b, 1, accuracy:0.00000001)
		XCTAssertEqual(transform.c, -1, accuracy:0.00000001)
		XCTAssertEqual(transform.d, 0, accuracy:0.00000001)
		XCTAssertEqual(transform.dx, 0, accuracy:0.00000001)
		XCTAssertEqual(transform.dy, 0, accuracy:0.00000001)
		
		let rotated = transform.transform(Point(x: 1.0, y: 0.0))
		XCTAssertEqual(rotated.x, 0.0, accuracy: 0.00000001)
		XCTAssertEqual(rotated.y, 1.0, accuracy: 0.00000001)
		
	}
	
	func testPointTranslation() {
		let transform = Transform2D(translateX: 3.7, y: 5.8)
		XCTAssertEqual(transform.a, 1, accuracy:0.00000001)
		XCTAssertEqual(transform.b, 0, accuracy:0.00000001)
		XCTAssertEqual(transform.c, 0, accuracy:0.00000001)
		XCTAssertEqual(transform.d, 1, accuracy:0.00000001)
		XCTAssertEqual(transform.dx, 3.7, accuracy:0.00000001)
		XCTAssertEqual(transform.dy, 5.8, accuracy:0.00000001)
		
		let rotated = transform.transform(Point(x: 1.0, y: 0.0))
		XCTAssertEqual(rotated.x, 4.7, accuracy: 0.00000001)
		XCTAssertEqual(rotated.y, 5.8, accuracy: 0.00000001)
	}
	
	
	func testTranslateRotate() {
		let translation = Transform2D(translateX: 1.0, y: 0.0)
		let rotation = Transform2D(rotation: .pi/2)
		let concatenated = translation.concatenate(with: rotation)
		let newPoint = concatenated.transform(Point(x: 0.0, y: 0.0))
		XCTAssertEqual(newPoint.x, 0, accuracy:0.00000001)
		XCTAssertEqual(newPoint.y, 1, accuracy:0.00000001)
	}
	
	
	
	
	func testRotation() {

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
			.byAddingLine(to: Point(x: 10.0, y: 0.0))
			.byAddingLine(to: Point(x: 10.0, y: 10.0))
			.byAddingLine(to: Point(x: 0.0, y: 10.0))
			.byAddingLine(to: Point(x: 0.0, y: 0.0))
		context.currentState.applyTransformation(Transform2D(translateX: 20.0, y: 0.0))
		context.currentState.applyTransformation(Transform2D(rotation: SGFloat.pi / 8))
		context.drawPath(aPath, fillShader: SolidColorShader(color: colorSpace.black), stroke: nil)
		
		guard let pngData = context.image.pngData else {
			XCTFail("couldn't get png data")
			return
		}
		let outputFilePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("rotationTransformTest.png")
		try? pngData.write(to: outputFilePath)
		
	}
}
