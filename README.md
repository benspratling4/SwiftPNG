# SwiftPNG
Pure-Swift implementation of PNG file encoding and decoding

WIP: implements some encoding and decoding and algorithms, for some bit depths.

## Decoding

`let pngFileData:Data = ....`

`let image = SampledImage(pngData: pngFileData)`

## Encoding

`let image:SampledImage = ...`

`let pngFileData:Data? = image.pngData`


