//
//  SampledImage+PNGFile.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 11/1/17.
//

import Foundation
import SwiftGraphicsCore
import SwiftSampledGraphics


extension SampledImage {
	
	/// designated way to create an image of a .png file
	public convenience init(pngData:Data)throws {
		let file:PNGFile = try PNGFile(serializedData: pngData)
		try self.init(pngFile:file)
	}

	convenience init(pngFile:PNGFile)throws {
		//TODO: try to infer the color space better :)
		let imageData:Data = pngFile.imageData()
		var bytes:[UInt8] = [UInt8](repeating:0, count:imageData.count)
		imageData.copyBytes(to: &bytes, count: imageData.count)
		self.init(width: Int(pngFile.header.width), height: Int(pngFile.header.height), colorSpace: GenericRGBAColorSpace(hasAlpha:pngFile.header.colorType.contains(.alphaChannelUsed)), bytes: bytes)
	}
	
	///designated way to get a 
	public var pngData:Data? {
		//TODO: compress odd color spaces
		guard let file = try? PNGFile(imageData: Data(self.bytes), bytesPerChannel: colorSpace.bytesPerComponent, channelsPerPixel: colorSpace.componentCount, width: dimensions.width, height: dimensions.height) else {
			return nil
		}
		
		return file.serialize()
	}
	
}
