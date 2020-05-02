//
//  Data+Extensions.swift
//  SwiftBitCode
//
//  Created by Ben Spratling on 12/2/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import Foundation

public enum MsbUin32Error : Error {
	case insufficientCount(Int)
}

///The factories should use the BitStream instead
extension Data {
	///these bits are LSB first, not MSB first like human writing
	public func bits(at:Cursor, count:Int = 1)->([Bool], Cursor) {
		var cursor:Cursor = at
		var bits:[Bool] = []
		for _ in 0..<count {
			//get the byte at the cursor
			bits.append(self[cursor.byte].bit(at:cursor.bit))
			cursor = cursor.adding(bits: 1)
		}
		return (bits, cursor)
	}
	
	public func fixedInt(at:Cursor, count:Int = 1)->(Int, Cursor) {
		let (bits, cursor) = self.bits(at:at, count:count)
		return (Int(bits:bits), cursor)
	}
	
	public func char(at:Cursor)->(UInt8,Cursor) {
		//6 bits in a bit-code char
		let (value, cursor) = fixedInt(at: at, count:6)
		return (UInt8(value), cursor)
	}
	
	public func variableInts(at:Cursor, size:Int)->([Int], Cursor) {
		var ints:[Int] = []
		//write me
		var cursor:Cursor = at
		repeat {
			var (bits, c):([Bool], Cursor) = self.bits(at:cursor, count:size)
			cursor = c
			let lastBit = bits.last!
			bits = [Bool](bits.dropLast())
			let newValue = Int(bits:bits)
			ints.append(newValue)
			if lastBit == false { break }
		} while true
		return (ints, cursor)
	}
	
	public func variableInt(at:Cursor, size:Int)->(Int, Cursor) {
		var allBits:[Bool] = []
		//write me
		var cursor:Cursor = at
		repeat {
			let (bits, c):([Bool], Cursor) = self.bits(at:cursor, count:size)
			cursor = c
			let lastBit = bits.last!
			allBits.append(contentsOf: bits.dropLast())
			if lastBit == false { break }
		} while true
		return (Int(bits:allBits), cursor)
	}
	
	///does not use bits in reading the bytes, so bytes are always byte-aligned to the oriignal data
	public func bytes(at:Cursor, count:Int = 1)->([UInt8], Cursor) {
		let newCursor = at.adding(bytes: count)
		var bytes:[UInt8] = Array<UInt8>(repeating: 0, count: count)
		copyBytes(to: &bytes, from: at.byte..<newCursor.byte)
		return (bytes, newCursor)
	}
	
	
	func readMSBFixedWidthUInt<Result>(at offset:Int)throws->Result where Result:FixedWidthInteger, Result:UnsignedInteger {
		let byteCount:Int = Result.bitWidth / 8
		guard count >= offset + byteCount else {
			throw MsbUin32Error.insufficientCount(offset)
		}
		let placeHolder:Result = withUnsafeBytes { pointer in
			return pointer.load(fromByteOffset: offset, as: Result.self)
		}
		return Result(bigEndian: placeHolder)
	}
}
