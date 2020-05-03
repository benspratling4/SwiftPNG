# SwiftPNG
Pure-Swift implementation of PNG file encoding and decoding

WIP: implements some encoding and decoding and algorithms, for some bit depths.  

PNG file format spec:
http://www.libpng.org/pub/png/spec/1.2/PNG-Contents.html

## Decoding

`let pngFileData:Data = ....`

`let image = SampledImage(pngData: pngFileData)`

## Encoding

`let image:SampledImage = ...`

`let pngFileData:Data? = image.pngData`


