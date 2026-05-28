#!/usr/bin/env swift
import AppKit
import Foundation

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: make_contact_sheet.swift <input-folder> <output-jpg>\n", stderr)
    exit(2)
}

let folderURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
let fileManager = FileManager.default

let files = (try fileManager.contentsOfDirectory(
    at: folderURL,
    includingPropertiesForKeys: nil
))
.filter { $0.pathExtension.lowercased() == "png" }
.sorted { $0.lastPathComponent < $1.lastPathComponent }

guard !files.isEmpty else {
    fputs("No PNG files found in \(folderURL.path)\n", stderr)
    exit(1)
}

let thumbWidth: CGFloat = 260
let thumbHeight: CGFloat = 562
let padding: CGFloat = 24
let labelHeight: CGFloat = 32
let columns = 2
let rows = Int(ceil(Double(files.count) / Double(columns)))
let sheetSize = NSSize(
    width: CGFloat(columns) * thumbWidth + CGFloat(columns + 1) * padding,
    height: CGFloat(rows) * (thumbHeight + labelHeight) + CGFloat(rows + 1) * padding
)

let image = NSImage(size: sheetSize)
image.lockFocus()
NSColor.white.setFill()
NSRect(origin: .zero, size: sheetSize).fill()

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
    .foregroundColor: NSColor(calibratedWhite: 0.18, alpha: 1),
    .paragraphStyle: paragraph
]

for (index, file) in files.enumerated() {
    guard let source = NSImage(contentsOf: file) else {
        continue
    }

    let column = index % columns
    let row = index / columns
    let cellX = padding + CGFloat(column) * (thumbWidth + padding)
    let cellYFromTop = padding + CGFloat(row) * (thumbHeight + labelHeight + padding)
    let cellY = sheetSize.height - cellYFromTop - thumbHeight

    let scale = min(thumbWidth / source.size.width, thumbHeight / source.size.height)
    let drawSize = NSSize(width: source.size.width * scale, height: source.size.height * scale)
    let drawOrigin = NSPoint(
        x: cellX + (thumbWidth - drawSize.width) / 2,
        y: cellY + (thumbHeight - drawSize.height) / 2
    )
    source.draw(in: NSRect(origin: drawOrigin, size: drawSize))

    let labelRect = NSRect(x: cellX, y: cellY - labelHeight + 4, width: thumbWidth, height: labelHeight)
    file.lastPathComponent.draw(in: labelRect, withAttributes: attributes)
}

image.unlockFocus()

guard let tiffData = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else {
    fputs("Could not render contact sheet\n", stderr)
    exit(1)
}

try jpegData.write(to: outputURL, options: [.atomic])
