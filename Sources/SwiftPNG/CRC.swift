//
//  CRC.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 10/29/17.
//

import Foundation

//does not match crc's in test png's
class CRC {
	fileprivate static let eightBitCRCs:[UInt32] = calculate8BitCRCs()
	
	private static func calculate8BitCRCs()->[UInt32] {
		return (0..<256).map({ (n) -> UInt32 in
			var c:UInt32 = UInt32(n)
			for _ in 0..<8 {
				if c & UInt32(0x01) != 0 {
					c = 0xedb88320 ^ (c >> 1)
				} else {
					c = c >> 1
				}
			}
			return c
		})
	}
	
	fileprivate var value:UInt32 = 0xFFFFFFFF
	
	@discardableResult func update(bytes:[UInt8])->UInt32 {
		for byte in bytes {
			value = CRC.eightBitCRCs[Int((value ^ UInt32(byte)) & 0xff )] ^ (value >> 8)
		}
		return crc
	}
	
	var crc:UInt32 {
		return value ^ UInt32(0xFFFFFFFF)
	}
	
}

extension Data {
	var crc:UInt32 {
		let crcObject:CRC = CRC()
		for byte in self {
			crcObject.value = CRC.eightBitCRCs[Int((crcObject.value ^ UInt32(byte)) & 0xff )] ^ (crcObject.value >> 8)
		}
		return crcObject.crc
	}
}
