//
//  Chunk.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 10/28/17.
//

import Foundation

extension UInt32 {
	var msbBytes:[UInt8] {
		var bytes:[UInt8] = []
		var register:UInt32 = self
		for _ in 0..<4 {
			let syth = register & 0xFF000000
			bytes.append(UInt8(syth >> 24))
			register = register << 8
		}
		return bytes
	}
}


public struct Chunk {
	public var code:[UInt8]
	///count must not be more than 2^31-1
	public var data:Data
	
	public var codeAsString:String? {
		return String(data: Data(code), encoding: .ascii)
	}
	
	///code must have 4 bytes, data.count < (2^31-1)
	public init?(code:[UInt8], data:Data) {
		if code.count != 4 {
			return nil
		}
		if data.count > 2147483647 {
			return nil
		}
		self.code = code
		self.data = data
	}
	
	public init?(code:String, data:Data) {
		guard let codeBytes = code.data(using: .ascii) else {
			return nil
		}
		if codeBytes.count != 4 {
			return nil
		}
		if data.count > 2147483647 {
			return nil
		}
		self.code = [codeBytes[0], codeBytes[1], codeBytes[2], codeBytes[3]]
		self.data = data
	}
	
	public var serializedData:Data {
		var finalData:Data = Data()
		//prepend code
		finalData.append(contentsOf: code)
		//append data
		finalData.append(contentsOf: data)
		//calculate crc
		let crc = finalData.crc
		//append crc
		finalData.append(contentsOf: crc.msbBytes)
		//prepend length
		finalData.insert(contentsOf:UInt32(data.count).msbBytes, at: 0)
		return finalData
	}
}


struct ChunkInfo {
	var startIndex:Int
	var length:UInt32
	///always 4 bytes
	var code:[UInt8]
	var crc:UInt32
	
	var codeAsString:String? {
		return String(data: Data(code), encoding: .utf8)
	}
	
	var isCritical:Bool {
		return !code[0].bit(at: 5)
	}
	
	var isPublic:Bool {
		return !code[1].bit(at: 5)
	}
	
	var isRecognized:Bool {
		return !code[2].bit(at: 5)
	}
	
	var isSafeToCopy:Bool {
		return !code[3].bit(at: 5)
	}
	
	func chunk(in data:Data)->Chunk? {
		return Chunk(code: code, data: Data(data[startIndex+8..<startIndex+8+Int(length)]))
	}
	
}


class ChunkInfoFactory {
	
	let stream:BitStream
	
	init(data:Data) {
		self.stream = BitStream(data: data, cursor: Cursor(byte: 8, bit: 0))
	}
	
	lazy var allChunks:[ChunkInfo] = self.readAllChunks()
	
	func readAllChunks()->[ChunkInfo] {
		var chunks:[ChunkInfo] = []
		while let chunk = readChunk() {
			chunks.append(chunk)
		}
		return chunks
	}
	
	
	func readChunk()->ChunkInfo? {
		let startIndex:Int = stream.cursor.byte
		if stream.cursor.byte + 12 > stream.data.count {
			return nil
		}
		let length:UInt32 = stream.readInt()
		if Int(length) + stream.cursor.byte + 8 > stream.data.count {
			return nil//insufficient bytes in the chunk to read a chunk
		}
		
		let code:[UInt8] = stream.bytes(width: 4)
		stream.advance(byteCount:Int(length))
		let crc:UInt32 = stream.readInt()
		return ChunkInfo(startIndex: startIndex, length: length, code: code, crc: crc)
	}
	
	
	class func isChunkSequenceValid(_ chunks:[ChunkInfo])->Bool {
		if chunks.count < 3 {
			return false
		}
		
		//IHDR must be first chunk
		if chunks[0].code != [0x49, 0x48, 0x44, 0x52] {
			return false
		}
		
		//IEND must be last chunk
		if chunks.last!.code != [0x49, 0x45, 0x4e, 0x44] {
			return false
		}

		//at least one IDAT hunk
		let idatHunks:[ChunkInfo] = chunks.filter { return $0.code == [0x49, 0x44, 0x41, 0x54]}
		if idatHunks.count == 0 {
			return false
		}
		
		//TODO: more validation?
		return true
	}
	
	func chunkWithCode(_ code:String)->ChunkInfo? {
		for chunk in allChunks {
			if chunk.codeAsString == code {
				return chunk
			}
		}
		return nil
	}
	
	func chunksWithCode(_ code:String)->[ChunkInfo] {
		return allChunks.filter({return $0.codeAsString == code})
	}
	
	lazy var imageHeader:ImageHeader? = self.findImageHeader()
	
	func findImageHeader()->ImageHeader? {
		guard let chunk = chunkWithCode("IHDR") else {
			return nil
		}
		return ImageHeader(stream: stream, chunk: chunk)
	}
	
	lazy var idatChunks:[ChunkInfo] = self.chunksWithCode("IDAT")
	
}


