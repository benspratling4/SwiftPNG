//
//  Adler32.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 11/4/17.
//

import Foundation


class Adler32 {
	
	init(value:UInt32 = 1) {
		s1 = value & 0xFFFF
		let subvalue = value >> 16
		s2 = subvalue
	}
	
	var s1:UInt32 = 1
	var s2:UInt32 = 0
	
	func append(_ byte:UInt8) {
		s1 += UInt32(byte)
		s1 = s1 % 65521
		s2 = s2+s1
		s2 = s2 % 65521
	}
	
	var value:UInt32 {
		return (s2<<16) + s1
	}
}

extension Data {
	var adler32:UInt32 {
		let adler = Adler32()
		for byte in self {
			adler.append(byte)
		}
		return adler.value
	}
}
