//
//  ColorPallette.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 10/30/17.
//

import Foundation


public struct ColorPallette {
	
	init?(data:Data, info:ChunkInfo) {
		if info.codeAsString != "PLTE" {
			return nil
		}
		if info.length % 3 != 0 {
			return nil
		}
		let colorsStarIndex:Int = info.startIndex + 8
		colors = (0..<info.length/3).map({ return Color(red: data[colorsStarIndex+(3*Int($0))],
		                                                green: data[colorsStarIndex+(3*Int($0))+1],
		                                                blue: data[colorsStarIndex+(3*Int($0))+2])
		})
	}
	
	struct Color {
		var red:UInt8
		var green:UInt8
		var blue:UInt8
	}
	
	//outside index is the value in the imagedata
	//inside index = 0
	var colors:[Color] = []
	
	var chunk:Chunk {
		let bytes:[UInt8] = colors.flatMap { (color) -> [UInt8] in
			return [color.red, color.green, color.blue]
		}
		return Chunk(code: "PLTE", data: Data(bytes))!
	}
	
}
