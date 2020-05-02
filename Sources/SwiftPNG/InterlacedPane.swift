//
//  InterlacedPane.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 10/31/17.
//

import Foundation

///represents unfiltered data in one of the interlaced patterns
struct InterlacedPane {
	
	struct InterlacePattern {
		var xOffset:Int
		var yOffset:Int
		//show every _ pixels
		var xPeriod:Int
		var yPeriod:Int
	}
	
	static let adam7InterlacePatterns:[InterlacePattern] = [
		InterlacePattern(xOffset: 0, yOffset: 0, xPeriod: 8, yPeriod: 8),
		InterlacePattern(xOffset: 4, yOffset: 0, xPeriod: 8, yPeriod: 8),
		InterlacePattern(xOffset: 0, yOffset: 4, xPeriod: 4, yPeriod: 8),
		InterlacePattern(xOffset: 2, yOffset: 0, xPeriod: 2, yPeriod: 4),
		InterlacePattern(xOffset: 0, yOffset: 2, xPeriod: 2, yPeriod: 4),
		InterlacePattern(xOffset: 1, yOffset: 0, xPeriod: 1, yPeriod: 2),
		InterlacePattern(xOffset: 0, yOffset: 1, xPeriod: 1, yPeriod: 2),
		]
	
	static let noInterlacePatterns:[InterlacePattern] = [
		InterlacePattern(xOffset: 0, yOffset: 0, xPeriod: 1, yPeriod: 1)
	]
	
	var pattern:InterlacePattern
	var width:Int
	var height:Int
	var data:Data
	
}

extension Array where Element == InterlacedPane {
	
	func stichTogether(header:ImageHeader)->Data {
		let panes:[InterlacedPane] = self
		if panes.count == 1 {
			return panes[0].data
		}
		if header.bitDepth < 8 {
			//TODO: do bit-specific stuff
			fatalError("write bit packing math")
		}
		
		var finalByteCount:Int = 0
		for pane in panes {
			finalByteCount += pane.data.count
		}
		var finalData:Data = Data(repeating: 0, count: finalByteCount)
		let pixelSize:Int = header.bitDepth == 16 ? 2 : 1
		let imageWidth:Int = Int(header.width)
		let samplesPerPixel:Int = header.colorType.filterChannelCount
		for pane in panes {
			for row in 0..<pane.height {
				for column in 0..<pane.width {
					let coordinateOfPixelInPaneData:Int = (row * pane.width + column) * pixelSize
					let finalPixelX:Int = pane.pattern.xOffset + (pane.pattern.xPeriod * column)
					let finalPixelY:Int = pane.pattern.yOffset + (pane.pattern.yPeriod * row)
					let byteInFinalData:Int = pixelSize * (imageWidth * finalPixelY + finalPixelX)
					finalData[byteInFinalData..<byteInFinalData+(pixelSize*samplesPerPixel)] = pane.data[coordinateOfPixelInPaneData..<byteInFinalData+(pixelSize*samplesPerPixel)]
				}
			}
		}
		return finalData
	}
	
}


