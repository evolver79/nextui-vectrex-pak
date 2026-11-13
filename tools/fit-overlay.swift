// Fits a Vectrex overlay image onto the TrimUI Brick screen for NextUI (macOS, CoreGraphics only).
//
// NextUI draws an overlay over the whole 1024x768 screen; vecx's 33:41 picture (Aspect scaling) sits in the middle at
// x=203, 618x768. This stretches the overlay over exactly that area on a transparent canvas. Overlays that are solid
// in the middle (most of them, made for emulators that blend them differently) would hide the game, so their opacity
// is scaled down to the given level; overlays that are already see-through are left as they are.
//
// Build:  swiftc -O -o fit-overlay tools/fit-overlay.swift
// Use:    ./fit-overlay <in.png> <out.png> [opacity, default 0.25]
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let args = CommandLine.arguments
guard args.count >= 3,
      let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: args[1]) as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
  print("usage: fit-overlay <in.png> <out.png> [opacity]"); exit(1)
}
let opacity = args.count > 3 ? Double(args[3]) ?? 0.25 : 0.25

let W = 1024, H = 768
let gameW = Int((Double(H) * 33.0 / 41.0).rounded()), gameX = (W - gameW) / 2
let ctx = CGContext(data: nil, width: W, height: H, bitsPerComponent: 8, bytesPerRow: W * 4,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.clear(CGRect(x: 0, y: 0, width: W, height: H))
ctx.interpolationQuality = .high
ctx.draw(img, in: CGRect(x: gameX, y: 0, width: gameW, height: H))

// Mean alpha of the middle of the game area.
let px = ctx.data!.bindMemory(to: UInt8.self, capacity: W * H * 4)
var sum = 0.0, n = 0.0
for y in (H / 4)..<(3 * H / 4) {
  for x in (gameX + gameW / 4)..<(gameX + 3 * gameW / 4) { sum += Double(px[(y * W + x) * 4 + 3]); n += 1 }
}
let mean = sum / n / 255.0
if mean > 0.8 {
  let k = opacity / mean   // premultiplied, so colour and alpha scale together
  for i in 0..<(W * H * 4) { px[i] = UInt8(min(255.0, Double(px[i]) * k)) }
}

let dst = CGImageDestinationCreateWithURL(URL(fileURLWithPath: args[2]) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dst, ctx.makeImage()!, nil)
CGImageDestinationFinalize(dst)
print(String(format: "centre alpha %.2f", mean) + (mean > 0.8 ? String(format: " -> %.2f", opacity) : " (kept)") + "  \(args[2])")
