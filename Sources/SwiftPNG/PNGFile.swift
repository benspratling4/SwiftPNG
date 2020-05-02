//
//  PNGFile.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 10/28/17.
//

import Foundation
import SwiftFoundationCompression

public enum PNGFileError : Error {
	case fileCorrupted
	case invalidFormat
	case unsupportedFormat
}

///Directly represents the format of a .png file
///	TODO: 1-4 bit support when interlacing
/// TODO: tIME chunk
/// TODO: tRNS chunk	- transparency
/// TODO: zTXt, tEXt, iTXt, chunks
/// TODO: iCCP, cHRM, sRGB chunks
/// TODO: streaming support

///TODO: 1-4-bit, text, transparency, color profile support
public class PNGFile {
	
	///i.e. init with the contents of a file
	public convenience init(serializedData:Data)throws {
		let factory = ChunkInfoFactory(data: serializedData)
		let chunks:[ChunkInfo] = factory.allChunks
		try self.init(data: serializedData, chunkInfos: chunks)
	}
	
	init(data:Data, chunkInfos:[ChunkInfo])throws {
		if !ChunkInfoFactory.isChunkSequenceValid(chunkInfos) {
			throw PNGFileError.invalidFormat
		}
		let factory = ChunkInfoFactory(data: data)
		guard let header = factory.imageHeader else {
			throw PNGFileError.invalidFormat
		}
		self.header = header
		//TODO: validate bit depth / color type options
		if let plteChunk = chunkInfos.filter({return $0.codeAsString == "PLTE"}).first {
			self.colorPallette = ColorPallette(data: data, info: plteChunk)
		}
		//TODO: validate whether palette is required, or restricted
		let idats:[ChunkInfo] = factory.idatChunks
		var allData:Data = Data()
		for chunk in idats {
			let subData = data[(chunk.startIndex + 8)..<(chunk.startIndex + 8 + Int(chunk.length))]
			//TODO: crc check
			
			allData.append(subData)
		}
		let trimmed:Data = Data(allData[2..<allData.count-2])
		guard let decompressedData:Data = try? trimmed.decompressed(using:.deflate) else {
			throw PNGFileError.fileCorrupted
		}
		self.filteredImageData = decompressedData
		
		//find gamma
		if let gammaChunk = chunkInfos.filter({return $0.codeAsString == "gAMA"}).first {
			let reader = BitStream(data: data, cursor: Cursor(byte: gammaChunk.startIndex+8, bit: 0))
			let gammaInt:UInt32 = reader.readInt()
			let gammaFloat:Float32 = Float32(gammaInt)
			self.gamma = gammaFloat / 100_000.0
		}
		if let transparencyChunk = chunkInfos.filter({ $0.codeAsString == "tRNS"}).first {
			transparency = TransparencyTable(data: data, info: transparencyChunk, colorType:header.colorType)
		}
		try divideUnrecognizedChunks(data:data, infos: chunkInfos)
		
		var txtRecords:[TextRecord] = chunkInfos.filter({$0.codeAsString == TextChunck.chunkCode}).compactMap({ TextChunck(data: data, info: $0)?.textRecord })
		var compressedTextRecords:[TextRecord] = chunkInfos.filter({$0.codeAsString == CompressedTextChunk.chunkCode}).compactMap({ CompressedTextChunk(data: data, info: $0)?.textRecord })
		txtRecords.append(contentsOf: compressedTextRecords)
		textRecords = txtRecords
		internationalTextRecords = chunkInfos.filter({$0.codeAsString == InternationalTextChunk.chunkCode}).compactMap({ InternationalTextChunk(data: data, info: $0)?.textRecord })
	}
	
	//supported when reading, TODO: writing
	var textRecords:[TextRecord]?
	var internationalTextRecords:[InterntionalTextRecord]?
	
	public init(header:ImageHeader, filteredImageData:Data) {
		self.header = header
		self.filteredImageData = filteredImageData
	}
	
	///creates a true-color .png with 8 or 16-bit channels, grayscale, rgb or either with alpha channels
	public convenience init(imageData:Data, bytesPerChannel:Int, channelsPerPixel:Int, width:Int, height:Int) throws {
		//validate the format
		if imageData.count < bytesPerChannel * channelsPerPixel * width * height {
			throw PNGFileError.invalidFormat
		}
		if bytesPerChannel < 1 || bytesPerChannel > 2 {
			throw PNGFileError.invalidFormat
		}
		if channelsPerPixel < 1 || channelsPerPixel > 4 {
			throw PNGFileError.invalidFormat
		}
		if width < 1 || width > 2147483647 {
			throw PNGFileError.invalidFormat
		}
		if height < 1 || height > 2147483647 {
			throw PNGFileError.invalidFormat
		}
		var colorType:ImageHeader.ColorType = ImageHeader.ColorType()
		switch channelsPerPixel {
		case 1:
			colorType = []
		case 2:
			colorType = [.alphaChannelUsed]
		case 3:
			colorType = [.colorUsed]
		case 4:
			colorType = [.colorUsed, .alphaChannelUsed]
		default:
			throw PNGFileError.invalidFormat
		}
		//filter the data
		let layout:ScanLine.Layout = ScanLine.Layout(pixelCount: width, bitDepth: bytesPerChannel * 8, channels: channelsPerPixel)
		let bytesPerLine:Int = layout.dataByteCount
		var filteredData:Data = Data()
		var previousScanLine:ScanLine = ScanLine(filterAlgorithm: .none, layout: layout, bytes: nil)
		for row in 0..<height {
			let lineStart:Int = row * bytesPerLine
			let unfilteredLine:ScanLine = ScanLine(filterAlgorithm: .none, layout: layout, bytes: Data(imageData[lineStart..<lineStart+bytesPerLine]))
			let filteredLine:ScanLine = unfilteredLine.adaptivelyFiltered(previous: previousScanLine)
			filteredData.append(filteredLine.filterAlgorithm.rawValue)
			filteredData.append(filteredLine.bytes)
			previousScanLine = unfilteredLine
		}
		self.init(header: ImageHeader(width: UInt32(width), height: UInt32(height), bitDepth: UInt8(bytesPerChannel*8), colorType: colorType, compressionMethod: .deflate, filterMethod: .adaptiveFilteringWithFiveBasicFilterTypes, interlaceMethod: .none), filteredImageData: filteredData)
	}
	
	public var header:ImageHeader
	
	public var colorPallette:ColorPallette?
	
	public var transparency:TransparencyTable?
	
	public var gamma:Float32?
	
	//filtered or compressed....  or uncompressed and unfiltered?...
	public var filteredImageData:Data
	
	public var prePalletChunks:[Chunk] = []
	
	//does not include IHDR
	public var preIDATChunks:[Chunk] = []
	
	//does not include IEND
	public var postIDATChunks:[Chunk] = []
	
	 func divideUnrecognizedChunks(data:Data, infos:[ChunkInfo])throws {
		var includesPallette:Bool = false
		var startedIDat:Bool = false
		var finishedIDat:Bool = false
		
		for info in infos {
			guard let code = info.codeAsString else { continue }
			switch code {
			case "IHDR":
				if let _ = info.chunk(in: data) {
					//check crc?
					//if chunk.serializedData
				}
				
				continue
			case "PLTE":
				includesPallette = true
				continue
			case "IDAT":
				if finishedIDat {
					//problem, IDAT must be consecutive
					throw PNGFileError.invalidFormat
				}
				startedIDat = true
				continue
			case "IEND":
				continue
			case "gAMA":
				continue
			default:
				if info.isCritical {
					throw PNGFileError.unsupportedFormat
				}
				if startedIDat {
					finishedIDat = true
				}
			}
			
			guard let chunk = info.chunk(in:data) else { continue }
			switch (includesPallette, startedIDat, finishedIDat) {
			case (false, false, false):
				prePalletChunks.append(chunk)
			case (true, false, false):
				preIDATChunks.append(chunk)
			case (_, true, false):
				postIDATChunks.append(chunk)
			case (_, true, true):
				break	//should never reach here
			case (_, false, true) :
				break	//should never reach here
			}
		}
	}
	
	
	func compareAllChunksTOCRC(data:Data, infos:[ChunkInfo]) {
		for info in infos {
			//crc applies to the code & data, but not length and crc fields
			let subData = Data(data[(info.startIndex+4)..<(info.startIndex+8+Int(info.length))])
			var allBytes:[UInt8] = [UInt8](repeating:0, count:subData.count)
			subData.copyBytes(to: &allBytes, from: 0..<subData.count)
			if info.length == 0 {
				print("check this one out")
			}
			//subData.copyBytes(to: &allBytes)
			let crc = CRC()
			crc.update(bytes: allBytes)
//			let crccrc = crc.crc
		}
	}
	
	func unfilterPaneData(data:Data, width:Int, height:Int)->Data {
		if width == 0 || height == 0 {
			return Data()
		}
		let lineLayout:ScanLine.Layout = ScanLine.Layout(pixelCount: width, bitDepth: Int(header.bitDepth), channels: header.colorType.filterChannelCount)
		let byteCount:Int = lineLayout.dataByteCount
		var lastLine = ScanLine(layout: lineLayout)
		var unfilteredData:Data = Data()
		var byteIndex:Int = 0
		for _ in 0..<height {
			//read a filter-type byte
			let filterTypeByte:UInt8 = data[byteIndex]
			byteIndex += 1
			guard let algorithm:ScanLine.FilterAlgorihtm = ScanLine.FilterAlgorihtm(rawValue: filterTypeByte) else { continue }
			var thisLine = ScanLine(filterAlgorithm:algorithm, layout: lineLayout, bytes:Data(data[byteIndex..<(byteIndex + byteCount)]))
			thisLine.unfilter(withPrevious: lastLine)
			unfilteredData.append(thisLine.bytes)
			lastLine = thisLine
			byteIndex += byteCount
		}
		return unfilteredData
	}
	
	
	///filtering takes place on each pane of an interlaced image...  so divide up the data in panes, then unfilter, than stitch together
	func interlacePanesFilteredData()->[(InterlacedPane.InterlacePattern, Data, Int, Int)] {
		if header.interlaceMethod == .none {
			return [(InterlacedPane.noInterlacePatterns[0], filteredImageData, Int(header.width), Int(header.height))]
		}
		
		let scanLineLayoutsAndRowCounts:[(InterlacedPane.InterlacePattern, ScanLine.Layout, Int)] = InterlacedPane.adam7InterlacePatterns.map({ (pass) -> (InterlacedPane.InterlacePattern, ScanLine.Layout, Int) in
			let horizontalPixelCount:Int = (Int(header.width)-pass.xOffset)/pass.xPeriod
			let verticalPixelCount:Int = (Int(header.height)-pass.yOffset)/pass.yPeriod
			return (pass, ScanLine.Layout(pixelCount:horizontalPixelCount,
			                 bitDepth:Int(header.bitDepth),
			                 channels:Int(header.colorType.filterChannelCount)),
				 verticalPixelCount)
		})
		
		var dataIndex:Int = 0
		return scanLineLayoutsAndRowCounts.map { (layoutAndLineCount) -> (InterlacedPane.InterlacePattern, Data, Int, Int) in
			if layoutAndLineCount.1.dataByteCount == 0 {
				return (layoutAndLineCount.0, Data(), 0, 0)
			}
			let paneByteCount:Int = layoutAndLineCount.2 * (1+layoutAndLineCount.1.dataByteCount)
			defer {
				dataIndex += 1+paneByteCount
			}
			return (layoutAndLineCount.0,
			        Data(filteredImageData[dataIndex..<1+paneByteCount+dataIndex]),
			        layoutAndLineCount.1.pixelCount,
			        layoutAndLineCount.2)
		}
	}
	
	///fully decompressed, unfiltered, and ready to use in an image
	func imageData()->Data {
		//the data will be what it is once we deinterlace & unfilter it
		let panesFilteredData:[(InterlacedPane.InterlacePattern, Data, Int, Int)] = interlacePanesFilteredData()
		let unfilteredData:[InterlacedPane] = panesFilteredData.map({ (pattern, data, width, height) -> InterlacedPane in
			let newData:Data = unfilterPaneData(data: data, width: width, height: height)
			return InterlacedPane(pattern: pattern, width: width, height: height, data: newData)
		})
		let stitchedData:Data
		if header.bitDepth >= 8 {
			stitchedData = unfilteredData.stichTogether(header: header)
		} else {
			stitchedData = unfilteredData.stitchTogetherLowBitDepthRaw(header: header)
		}
		guard let pallet = self.colorPallette else {
			//TODO: if there is a transparency table use it
			if header.bitDepth >= 8 {
				return stitchedData
			}
			return stitchedData.expandRawBits(from:Int(header.bitDepth))
		}
		return stitchedData.colored(with:pallet, transparency:transparency)
	}
	
	
	var gammaChunk:Chunk? {
		guard let gamma = self.gamma else { return nil }
		let storedValue:Float32 = gamma * 100_000.0
		let intStoredValue:UInt32 = UInt32(storedValue)
		let storedBytes:[UInt8] = intStoredValue.msbBytes
		return Chunk(code: "gAMA", data: Data(storedBytes))!
	}
	
	
	public func serialize()->Data {
		//start with signature
		var allData = Data([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
		//image header chunk
		allData.append(contentsOf: header.chunk.serializedData)
		
		//prepallet chunks
		for chunk in prePalletChunks {
			allData.append(chunk.serializedData)
		}
		//gamma must be pre-pallette
		if let gammaChunk = self.gammaChunk {
			allData.append(gammaChunk.serializedData)
		}
		
		//pallet, if envNotPresent
		if let pallet = colorPallette {
			allData.append(pallet.chunk.serializedData)
		}
		
		//pre-idat chunks
		for chunk in preIDATChunks {
			allData.append(chunk.serializedData)
		}
		
		//compress image data
		guard var compressedData = try? filteredImageData.compressed(using: .deflate) else {
			return Data()
		}
		
		//calculate adler-32
		compressedData.append(contentsOf: filteredImageData.adler32.msbBytes)
		
		//prepend 2 bytes which start the zip stream
		compressedData.insert(contentsOf: [0x78, 0x01], at: 0)
		//compressedData.append(contentsOf:check.msbBytes)
		//divide image data into chunks...
		while compressedData.count > 0 {
			let byteCountToCopy:Int = min(compressedData.count, 4096)
			let chunk = Chunk(code: "IDAT", data: Data(compressedData[0..<byteCountToCopy]))!
			allData.append(chunk.serializedData)
			compressedData.removeFirst(byteCountToCopy)
		}
		
		//post-idat chunks
		for chunk in postIDATChunks {
			allData.append(chunk.serializedData)
		}
		
		//iend chunk
		allData.append(Chunk(code:"IEND", data: Data())!.serializedData)
		return allData
	}
	
}
