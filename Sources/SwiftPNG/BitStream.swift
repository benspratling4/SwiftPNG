//
//  BitStream.swift
//  SwiftBitCode
//
//  Created by Ben Spratling on 12/3/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import Foundation

///reads bit-code specific integer formats from a Data.
///Keeps track of its location with an internal Cursor, automatically advances when reading
public class BitStream {
	public var cursor:Cursor
	public var data:Data
	public init(data:Data, cursor:Cursor) {
		self.data = data
		self.cursor = cursor
	}
	
	public func seek(to: Cursor) {
		cursor = to
	}
	
	public func roundUpCursorTo32Bits() {
		cursor = cursor.roundingUpTo32()
	}
	
	public func advance(byteCount:Int) {
		cursor = cursor.adding(bytes: byteCount)
	}
	
	///all of these functions advance the cursor
	
	public func bits(width:Int)->[Bool] {
		let bits:[Bool]
		(bits, cursor) = data.bits(at: cursor, count: width)
		return bits
	}
	
	public func bytes(width:Int)->[UInt8] {
		let (bytes, newCursor) = data.bytes(at: cursor, count: width)
		cursor = newCursor
		return bytes
	}
	
	public func readInt()->UInt32 {
		let pieces:[UInt8] = bytes(width: 4)
		var value:UInt32 = 0
		for byte in pieces {
			value *= 256
			value += UInt32(byte)
		}
		return value
	}
	
	
	/*
	///ignores cursor
	public func readInt32()->UInt32 {
		//read four bytes
		
		
	}
*/
	/*
	public func fixedInt(width:Int)->Int {
		let bits:[Bool]
		(bits, cursor) = data.bits(at: cursor, count: width)
		return Int(bits:bits)
	}
*/
	/*
	public func byte()->UInt8 {
		//6 bits in a bit-code char
		return UInt8(fixedInt(width:8))
	}
*/
	
}
