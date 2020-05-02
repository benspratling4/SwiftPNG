//
//  Transparency.swift
//  
//
//  Created by Ben Spratling on 5/2/20.
//

import Foundation



public struct TransparencyTable {
	
	var mapping:TransparencyMapping
	
	//for indexed color
	public func transparency(index indexedColor:Int)->UInt8 {
		guard case .indexed(let values) = mapping else {
			return 255
		}
		if indexedColor >= values.count {
			return 255
		}
		return values[Int(indexedColor)]
	}
	
	//if gray color is less than 16 bits, the bits are lsb-aligned in these UInt16'a
	public func transparency(gray color:UInt16)->UInt16 {
		guard case .grayscale(let gray) = mapping else {
			return 0xFFFF
		}
		return gray == color ? 0 : 0xFFFF
	}
	
	public func transparency(red:UInt16, green:UInt16, blue:UInt16)->UInt16 {
		guard case .rgb(let redTrans, let greenTrans, let blueTrans) = mapping else {
			return 0xFFFF
		}
		return (red == redTrans && green == greenTrans && blue == blueTrans) ? 0 : 0xFFFF
	}
	
	init?(data:Data, info:ChunkInfo, colorType:ImageHeader.ColorType) {
		if info.codeAsString != "tRNS" {
			return nil
		}
		switch colorType {
		case []:
			//get a single msb uint16
			guard let gray:UInt16 = try? data.readMSBFixedWidthUInt(at: info.startIndex + 8) else { return nil }
			mapping = .grayscale(gray)
		
		case [.colorUsed]:	//true color
			guard let red:UInt16 = try? data.readMSBFixedWidthUInt(at: info.startIndex + 8)
				,let green:UInt16 = try? data.readMSBFixedWidthUInt(at: info.startIndex + 10)
				,let blue:UInt16 = try? data.readMSBFixedWidthUInt(at: info.startIndex + 12)
				else { return nil }
			mapping = .rgb(red, green, blue)
			
		case [.paletteUsed, .colorUsed]:	//indexed color
			let alphaIndexCount:Int = Int(info.length)
			var indexedTransparencyValues:[UInt8] = [UInt8](repeating: 0, count:alphaIndexCount)
			_ = indexedTransparencyValues.withUnsafeMutableBytes { pointer in
				let startIndex:Int = info.startIndex + 8
				data.copyBytes(to: pointer, from: startIndex..<startIndex+alphaIndexCount)
			}
			mapping = .indexed(indexedTransparencyValues)
			
		default:
			return nil
		}
	}
	
	enum TransparencyMapping {
		///up to 256 alpha values, any indexes over the limit is 255
		case indexed([UInt8])
		
		//for both grayscale and rgb, if bit depth is less than 16, the bits are lbs-aligned inside the uint16
		case grayscale(UInt16)
		
		///the color value which should be treated as fully, all others are opaque
		case rgb(UInt16, UInt16, UInt16)
	}
}
