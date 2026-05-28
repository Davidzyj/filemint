import Foundation

enum ZipWriterError: LocalizedError {
    case fileTooLarge
    case invalidFileName

    var errorDescription: String? {
        switch self {
        case .fileTooLarge:
            return "The file is too large for this ZIP writer."
        case .invalidFileName:
            return "The ZIP entry name is invalid."
        }
    }
}

struct ZipWriter {
    private struct Entry {
        let nameData: Data
        let crc: UInt32
        let size: UInt32
        let offset: UInt32
        let modTime: UInt16
        let modDate: UInt16
    }

    private var handle: FileHandle
    private var entries: [Entry] = []
    private var offset: UInt32 = 0

    init(outputURL: URL) throws {
        FileManager.default.createFile(atPath: outputURL.path, contents: nil)
        handle = try FileHandle(forWritingTo: outputURL)
    }

    mutating func addFile(named name: String, data: Data, modifiedAt: Date = Date()) throws {
        guard let nameData = name.data(using: .utf8), !nameData.isEmpty else {
            throw ZipWriterError.invalidFileName
        }
        guard data.count <= UInt32.max, nameData.count <= UInt16.max else {
            throw ZipWriterError.fileTooLarge
        }

        let (modTime, modDate) = Self.dosDateTime(from: modifiedAt)
        let crc = CRC32.checksum(data)
        let size = UInt32(data.count)
        let entryOffset = offset

        var header = Data()
        header.appendUInt32(0x04034b50)
        header.appendUInt16(20)
        header.appendUInt16(0)
        header.appendUInt16(0)
        header.appendUInt16(modTime)
        header.appendUInt16(modDate)
        header.appendUInt32(crc)
        header.appendUInt32(size)
        header.appendUInt32(size)
        header.appendUInt16(UInt16(nameData.count))
        header.appendUInt16(0)

        try write(header)
        try write(nameData)
        try write(data)

        entries.append(
            Entry(
                nameData: nameData,
                crc: crc,
                size: size,
                offset: entryOffset,
                modTime: modTime,
                modDate: modDate
            )
        )
    }

    mutating func close() throws {
        guard entries.count <= UInt16.max else {
            throw ZipWriterError.fileTooLarge
        }

        let centralDirectoryOffset = offset

        for entry in entries {
            var directory = Data()
            directory.appendUInt32(0x02014b50)
            directory.appendUInt16(20)
            directory.appendUInt16(20)
            directory.appendUInt16(0)
            directory.appendUInt16(0)
            directory.appendUInt16(entry.modTime)
            directory.appendUInt16(entry.modDate)
            directory.appendUInt32(entry.crc)
            directory.appendUInt32(entry.size)
            directory.appendUInt32(entry.size)
            directory.appendUInt16(UInt16(entry.nameData.count))
            directory.appendUInt16(0)
            directory.appendUInt16(0)
            directory.appendUInt16(0)
            directory.appendUInt16(0)
            directory.appendUInt32(0)
            directory.appendUInt32(entry.offset)

            try write(directory)
            try write(entry.nameData)
        }

        let centralDirectorySize = offset - centralDirectoryOffset
        var end = Data()
        end.appendUInt32(0x06054b50)
        end.appendUInt16(0)
        end.appendUInt16(0)
        end.appendUInt16(UInt16(entries.count))
        end.appendUInt16(UInt16(entries.count))
        end.appendUInt32(centralDirectorySize)
        end.appendUInt32(centralDirectoryOffset)
        end.appendUInt16(0)

        try write(end)
        try handle.close()
    }

    private mutating func write(_ data: Data) throws {
        guard data.count <= UInt32.max - offset else {
            throw ZipWriterError.fileTooLarge
        }

        try handle.write(contentsOf: data)
        offset += UInt32(data.count)
    }

    private static func dosDateTime(from date: Date) -> (UInt16, UInt16) {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let year = max(1980, components.year ?? 1980)
        let month = components.month ?? 1
        let day = components.day ?? 1
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = (components.second ?? 0) / 2

        let dosTime = UInt16((hour << 11) | (minute << 5) | second)
        let dosDate = UInt16(((year - 1980) << 9) | (month << 5) | day)
        return (dosTime, dosDate)
    }
}

private enum CRC32 {
    private static let table: [UInt32] = {
        (0..<256).map { value in
            var crc = UInt32(value)
            for _ in 0..<8 {
                if crc & 1 == 1 {
                    crc = (crc >> 1) ^ 0xedb88320
                } else {
                    crc >>= 1
                }
            }
            return crc
        }
    }()

    static func checksum(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff
        for byte in data {
            let index = Int((crc ^ UInt32(byte)) & 0xff)
            crc = (crc >> 8) ^ table[index]
        }
        return crc ^ 0xffffffff
    }
}

private extension Data {
    mutating func appendUInt16(_ value: UInt16) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
    }

    mutating func appendUInt32(_ value: UInt32) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
    }
}
