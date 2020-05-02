//
//  File.swift
//  
//
//  Created by Ben Spratling on 5/2/20.
//

import Foundation



public struct TextRecord {
	public var keyword:String
	public var text:String
	
	public init(keyword:String, text:String) {
		self.keyword = keyword
		self.text = text
	}
}


struct TextChunck {
	
	static let chunkCode:String = "zTXt"
	
	var textRecord:TextRecord
	
	init?(data:Data, info:ChunkInfo) {
		if info.codeAsString != TextChunck.chunkCode {
			return nil
		}
		let dataLength:Int = Int(info.length)
		let dataStart:Int = info.startIndex+8
		var bytes:[UInt8] = [UInt8](repeating: 0, count: dataLength)
		_ = bytes.withUnsafeMutableBytes { pointer in
			data.copyBytes(to: pointer, from: dataStart..<dataStart+dataLength)
		}
		var keywordBytes:[UInt8] = []
		var textBytes:[UInt8] = []
		var hasEncounteredNull:Bool = false
		for byte in bytes {
			if hasEncounteredNull {
				textBytes.append(byte)
			} else {
				if byte == 0 {
					hasEncounteredNull = true
				} else {
					keywordBytes.append(byte)
				}
			}
		}
		guard let keyword:String = String(data: Data(keywordBytes), encoding: .isoLatin1)
			,let text:String = String(data: Data(textBytes), encoding: .isoLatin1)
			else { return nil }
		textRecord = TextRecord(keyword:keyword, text:text)
	}
}


struct CompressedTextChunk {
	static let chunkCode:String = "zTXt"
	
	var textRecord:TextRecord
	
	init?(data:Data, info:ChunkInfo) {
		if info.codeAsString != CompressedTextChunk.chunkCode {
			return nil
		}
		let dataLength:Int = Int(info.length)
		let dataStart:Int = info.startIndex+8
		var bytes:[UInt8] = [UInt8](repeating: 0, count: dataLength)
		_ = bytes.withUnsafeMutableBytes { pointer in
			data.copyBytes(to: pointer, from: dataStart..<dataStart+dataLength)
		}
		var keywordBytes:[UInt8] = []
		var textBytes:[UInt8] = []
		var hasEncounteredNull:Bool = false
		var compressionMethodByte:UInt8?
		for byte in bytes {
			if hasEncounteredNull {
				if compressionMethodByte == nil {
					compressionMethodByte = byte
				} else {
					textBytes.append(byte)
				}
			} else {
				if byte == 0 {
					hasEncounteredNull = true
				} else {
					keywordBytes.append(byte)
				}
			}
		}
		if compressionMethodByte != 0 {
			//0 means zip compression, no other methods documented
			return nil
		}
		guard let decompressedTextBytes = try? Data(textBytes).decompressed(using: .deflate)
			,let keyword:String = String(data: Data(keywordBytes), encoding: .isoLatin1)
				,let text:String = String(data: decompressedTextBytes, encoding: .isoLatin1)
				else { return nil }
		textRecord = TextRecord(keyword:keyword, text:text)
	}
	
}




struct InterntionalTextRecord {
	var keyword:String
	
	///like en-us, or x-klingon, case insensitive
	var lanugageTag:String
	var translatedKeyword:String?
	var text:String
}

struct InternationalTextChunk {
	static let chunkCode:String = "iTXt"
	
	var textRecord:InterntionalTextRecord
	
	init?(data:Data, info:ChunkInfo) {
		if info.codeAsString != InternationalTextChunk.chunkCode {
			return nil
		}
		let dataLength:Int = Int(info.length)
		let dataStart:Int = info.startIndex+8
		var bytes:[UInt8] = [UInt8](repeating: 0, count: dataLength)
		_ = bytes.withUnsafeMutableBytes { pointer in
			data.copyBytes(to: pointer, from: dataStart..<dataStart+dataLength)
		}
		
		/*
		Keyword:             1-79 bytes (character string)
		Null separator:      1 byte
		Compression flag:    1 byte
		Compression method:  1 byte
		Language tag:        0 or more bytes (character string)
		Null separator:      1 byte
		Translated keyword:  0 or more bytes
		Null separator:      1 byte
		Text:                0 or more bytes
		*/
		
		var keywordBytes:[UInt8] = []
		var runningIndex:Int = 0
		for byteIndex in runningIndex..<bytes.count {
			runningIndex = byteIndex
			let byte = bytes[byteIndex]
			if byte == 0 {
				break
			}
			keywordBytes.append(byte)
		}
		runningIndex += 1	//move past the null
		let compressionFlag = bytes[runningIndex]
		let compressionMethod = bytes[runningIndex+1]
		
		var languageTagBytes:[UInt8] = []
		runningIndex += 2
		for byteIndex in runningIndex..<bytes.count {
			runningIndex = byteIndex
			let byte = bytes[byteIndex]
			if byte == 0 {
				break
			}
			languageTagBytes.append(byte)
		}
		runningIndex += 1	//move past the null
		
		var translatedKeywordBytes:[UInt8] = []
		for byteIndex in runningIndex..<bytes.count {
			runningIndex = byteIndex
			let byte = bytes[byteIndex]
			if byte == 0 {
				break
			}
			translatedKeywordBytes.append(byte)
		}
		runningIndex += 1	//move past the null
		
		var textBytes:[UInt8] = []
		for byteIndex in runningIndex..<bytes.count {
			textBytes.append(bytes[byteIndex])
		}
		var textData:Data
		if compressionFlag == 1 {
			if compressionMethod != 0 {
				//only currently supported decompression method is inflate
				return nil
			}
			guard let decompressed = try? Data(textBytes).decompressed(using: .deflate) else {
				return nil
			}
			textData = decompressed
		} else {
			textData = Data(textBytes)
		}
		guard let keywordString = String(data: Data(keywordBytes), encoding: .isoLatin1)
			,let languageTagString = String(data: Data(languageTagBytes), encoding: .ascii)
			,let textString = String(data: textData, encoding: .utf8)
			else {
			return nil
		}
		
		let translatedKeywordString:String? = String(data: Data(translatedKeywordBytes), encoding: .utf8)
		
		textRecord = InterntionalTextRecord(keyword: keywordString, lanugageTag: languageTagString, translatedKeyword: translatedKeywordString, text: textString)
	}
	
}
