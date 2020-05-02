//
//  ImageHeader.swift
//  SwiftPNGTests
//
//  Created by Ben Spratling on 10/28/17.
//

import Foundation


public struct ImageHeader {
	public var width:UInt32
	
	public var height:UInt32
	
	public var bitDepth:UInt8
	public var colorType:ColorType
	public var compressionMethod:CompressionMethod
	public var filterMethod:FilterMethod
	public var interlaceMethod:InterlaceMethod
	
	public struct ColorType : OptionSet {
		public var rawValue: UInt8
		public init(rawValue:UInt8) {
			self.rawValue = rawValue
		}
		static let paletteUsed:ColorType = ColorType(rawValue: 1)
		static let colorUsed:ColorType = ColorType(rawValue: 2)
		static let alphaChannelUsed:ColorType = ColorType(rawValue: 4)
		
		//i.e. the number of channels in the filtered data
		public var filterChannelCount:Int {
			switch (contains(.paletteUsed), contains(.colorUsed))  {
			case (true, _):
				return 1
			case (false, false):
				return contains(.alphaChannelUsed) ? 2 : 1
			case (false, true):
				return contains(.alphaChannelUsed) ? 4 : 3
			}
		}
	}
	
	public enum CompressionMethod : UInt8 {
		case deflate = 0
	}
	
	public enum FilterMethod : UInt8 {
		case adaptiveFilteringWithFiveBasicFilterTypes = 0
	}
	
	public enum InterlaceMethod : UInt8 {
		case none = 0
		case adam7 = 1
	}
	
	public init(width:UInt32, height:UInt32, bitDepth:UInt8, colorType:ColorType, compressionMethod:CompressionMethod, filterMethod:FilterMethod, interlaceMethod:InterlaceMethod) {
		self.width = width
		self.height = height
		self.bitDepth = bitDepth
		self.colorType = colorType
		self.compressionMethod = compressionMethod
		self.filterMethod = filterMethod
		self.interlaceMethod = interlaceMethod
	}
	
	init?(stream:BitStream, chunk:ChunkInfo) {
		if chunk.codeAsString != "IHDR" {
			return nil
		}
		if chunk.length != 13 {
			return nil
		}
		let cursor = Cursor(byte: chunk.startIndex, bit: 0)
		stream.seek(to: cursor)
		stream.advance(byteCount: 8)
		let width:UInt32 = stream.readInt()
		let height:UInt32 = stream.readInt()
		if width == 0 || height == 0 || width > 2147483647 || height > 2147483647 {
			return nil
		}
		
		self.width = width
		self.height = height
		bitDepth = stream.bytes(width: 1)[0]
		colorType = ColorType(rawValue:stream.bytes(width: 1)[0])
		guard let compressionMethod = CompressionMethod(rawValue:stream.bytes(width: 1)[0]) else {
			//only inflate/deflate is supported
			return nil
		}
		self.compressionMethod = compressionMethod
		guard let filterMethod = FilterMethod(rawValue:stream.bytes(width: 1)[0]) else {
			return nil
		}
		self.filterMethod = filterMethod
		guard let interlaceMethod = InterlaceMethod(rawValue:stream.bytes(width: 1)[0]) else {
			return nil
		}
		self.interlaceMethod = interlaceMethod
	}
	
	
	var chunk:Chunk {
		var bytes:[UInt8] = width.msbBytes + height.msbBytes
		bytes.append(bitDepth)
		bytes.append(colorType.rawValue)
		bytes.append(compressionMethod.rawValue)
		bytes.append(filterMethod.rawValue)
		bytes.append(interlaceMethod.rawValue)
		return Chunk(code: "IHDR", data: Data(bytes))!
	}
	
}
