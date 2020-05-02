//
//  PNGFormatVerification.swift
//  SwiftPNG
//
//  Created by Ben Spratling on 10/28/17.
//

import Foundation

extension Data {
	public var isPNGFormat:Bool {
		//check leading bytes
		if count < 20 {
			return false
		}
		var leadingSignature:[UInt8] = Array<UInt8>(repeating: 0, count: 8)
		copyBytes(to: &leadingSignature, from: 0..<8)
		if leadingSignature != [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a] {
			return false
		}
		
		
		//other checks...read chunks?
		return true
	}
}

