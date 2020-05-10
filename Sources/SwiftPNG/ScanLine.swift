//
//  ScanLine.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 10/29/17.
//

import Foundation

struct ScanLine {
	
	struct Layout {
		var pixelCount:Int
		var bitDepth:Int	//1, 2, 4, 8, 16
		var channels:Int	//1, 2, 3, 4
		
		///how many bytes are required for the data, not including the leading byte, which lists the filter
		var dataByteCount:Int {
			//bits are "packed"
			let totalBits:Int = channels*bitDepth*pixelCount
			let roundUp:Int = (totalBits % 8 == 0) ? 0 : 1	//(if the bit deth is 16, the modulo will be 0, so we don't need to add one
			return totalBits / 8 + roundUp
		}
	}
	
	enum FilterAlgorihtm : UInt8 {
		case none, subtract, up, average, paeth
	}
	
	var filterAlgorithm:FilterAlgorihtm
	
	var bytes:Data
	
	var layout:Layout
	
	//if bytes are nil, data will be generated enough to hold the layout, with "0" values
	init(filterAlgorithm:FilterAlgorihtm = .none, layout:Layout, bytes:Data? = nil) {
		self.filterAlgorithm = filterAlgorithm
		self.layout = layout
		self.bytes = bytes ?? Data(repeating: 0, count: layout.dataByteCount)
	}
	
	///unfilter the scanline, when unfiltering the first scanline, provide a 0'd out scanline as the previous
	mutating func unfilter(withPrevious scanline:ScanLine) {
		func paethPredictor(a:UInt8, b:UInt8, c:UInt8)->UInt8 {
			let p = Int(a) + Int(b) - Int(c)
			let pa = abs(p - Int(a))
			let pb = abs(p - Int(b))
			let pc = abs(p - Int(c))
			if pa <= pb && pa <= pc { return a }
			else if pb <= pc { return b }
			else { return c }
		}
		
		func filter(x:UInt8, a:UInt8, b:UInt8, c:UInt8, isFirstOnLine:Bool)->UInt8 {
			switch filterAlgorithm {
				case .none:
					return x
				case .subtract:
					let orig:UInt8 = isFirstOnLine ? 0 : a
					return x &+ orig
				case .up:
					return x &+ b
				case .average:
					let orig:UInt8 = isFirstOnLine ? 0 : a
					let average:Int16 = Int16((UInt16(b) &+ UInt16(orig))/2)
					let signedX:Int16 = Int16(Int8(bitPattern:x))
					return UInt8(clamping:average &+ signedX)
				case .paeth:
					return x &+ paethPredictor(a:a, b:b, c:c)
			}
		}
		
		//if bit depth is 8 or more, handle pixel-wise operations
		if layout.bitDepth >= 8 {
			let bytesPerChannel:Int = layout.bitDepth/8
			let bytesPerPixel:Int = bytesPerChannel*layout.channels
			
			///start of the bytes for a given pixel & channel
			func byteIndex(pixel:Int, channel:Int)->Int {
				//before the pixel
				return bytesPerPixel * pixel + bytesPerChannel*channel
			}
			for pixel in 0..<layout.pixelCount {
				for channel in 0..<layout.channels {
					for byte in 0..<bytesPerChannel {
						let i:Int = byteIndex(pixel: pixel, channel: channel) + byte
						let isFirstOnLine:Bool = i < bytesPerPixel
						let a:UInt8 = isFirstOnLine ? 0 : bytes[i-bytesPerPixel]
						let b:UInt8 = scanline.bytes[i]
						let c = isFirstOnLine ? 0 : scanline.bytes[i-bytesPerPixel]
						bytes[i] = filter(x: bytes[i], a:a, b:b, c:c, isFirstOnLine:isFirstOnLine)
					}
				}
			}
		} else {
			for i in 0..<bytes.count {
				let isFirstOnLine:Bool = i < 1
				let a:UInt8 = isFirstOnLine ? 0 : bytes[i-1]
				let b:UInt8 = scanline.bytes[i]
				let c = isFirstOnLine ? 0 : scanline.bytes[i-1]
				bytes[i] = filter(x: bytes[i], a:a, b:b, c:c, isFirstOnLine:isFirstOnLine)
			}
		}
	}
	
	
	///unfilter the scanline, when unfiltering the first scanline, provide a 0'd out scanline as the previous
	mutating func filter(withPrevious scanline:ScanLine) {
		func paethPredictor(a:UInt8, b:UInt8, c:UInt8)->UInt8 {
			let p = Int(a) + Int(b) - Int(c)
			let pa = abs(p - Int(a))
			let pb = abs(p - Int(b))
			let pc = abs(p - Int(c))
			if pa <= pb && pa <= pc { return a }
			else if pb <= pc { return b }
			else { return c }
		}
		
		func filter(x:UInt8, a:UInt8, b:UInt8, c:UInt8, isFirstOnLine:Bool)->UInt8 {
			switch filterAlgorithm {
			case .none:
				return x
			case .subtract:
				let orig:UInt8 = isFirstOnLine ? 0 : a
				return x &- orig
			case .up:
				return x &- b
			case .average:
				let orig:UInt8 = isFirstOnLine ? 0 : a
				let average:Int16 = Int16(clamping:(UInt16(b) &+ UInt16(orig))/2)
				let diff:Int16 = Int16(x) - average
				return UInt8(bitPattern: Int8(clamping:diff))
			case .paeth:
				return x &- paethPredictor(a:a, b:b, c:c)
			}
		}
		
		//if bit depth is 8 or more, handle pixel-wise operations
		if layout.bitDepth >= 8 {
			let bytesPerChannel:Int = layout.bitDepth/8
			let bytesPerPixel:Int = bytesPerChannel*layout.channels
			
			///start of the bytes for a given pixel & channel
			func byteIndex(pixel:Int, channel:Int)->Int {
				//before the pixel
				return bytesPerPixel * pixel + bytesPerChannel*channel
			}
			for pixel in 0..<layout.pixelCount {
				for channel in 0..<layout.channels {
					for byte in 0..<bytesPerChannel {
						let i:Int = byteIndex(pixel: pixel, channel: channel) + byte
						let isFirstOnLine:Bool = i < bytesPerPixel
						let a:UInt8 = isFirstOnLine ? 0 : bytes[i-bytesPerPixel]
						let b:UInt8 = scanline.bytes[i]
						let c = isFirstOnLine ? 0 : scanline.bytes[i-bytesPerPixel]
						bytes[i] = filter(x: bytes[i], a:a, b:b, c:c, isFirstOnLine:isFirstOnLine)
					}
				}
			}
		} else {
			for i in 0..<bytes.count {
				let isFirstOnLine:Bool = i < 1
				let a:UInt8 = isFirstOnLine ? 0 : bytes[i-1]
				let b:UInt8 = scanline.bytes[i]
				let c = isFirstOnLine ? 0 : scanline.bytes[i-1]
				bytes[i] = filter(x: bytes[i], a:a, b:b, c:c, isFirstOnLine:isFirstOnLine)
			}
		}
	}
	
	///create a new scanline, which is adaptively filtered, based on the previous (unfiltered scanline)
	func adaptivelyFiltered(previous:ScanLine)->ScanLine {
		if layout.bitDepth < 8 {
			//the recommendations are to use no filtering if bit depth is less than 8
			return self
		}
		//create new scanlines with each filter type
		let filters:[FilterAlgorihtm] = [.none, .subtract, .up, .average, .paeth]
		let guesses:[ScanLine] = filters.map { (algorithm) -> ScanLine in
			var new = ScanLine(filterAlgorithm: algorithm, layout: layout, bytes: bytes)
			new.filter(withPrevious: previous)
			return new
		}
		return guesses[0]
		/*
		var guessesAndWeights:[(ScanLine, Int)] = guesses.map { (line) -> ((ScanLine, Int)) in
			var runningSum:Int = 0
			for byte in line.bytes {
				//creating a signed version of this byte
				var finalValue:Int8 = 0
				withUnsafeMutablePointer(to: &finalValue, { (finalPointer) -> () in
					finalPointer.withMemoryRebound(to: UInt8.self, capacity: 1, { (pointer) -> () in
						pointer.pointee = byte
					})
				})
				runningSum += Int(finalValue)
			}
			return (line, runningSum)
		}
		guessesAndWeights.sort { (a, b) -> Bool in
			return a.1 < b.1
		}
		return guessesAndWeights[0].0
*/
	}
	
}
