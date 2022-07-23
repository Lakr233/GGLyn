//
//  Data.swift
//  Lyn
//
//  Created by Lakr Aream on 2022/7/21.
//

import Foundation

extension Data {
    var hexEncodedString: String {
        map { String(format: "%02hhX", $0) }.joined()
    }

    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        var i = hex.startIndex
        for _ in 0 ..< len {
            let j = hex.index(i, offsetBy: 2)
            let bytes = hex[i ..< j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else { return nil }
            i = j
        }
        self = data
    }

    func createChunks(size chunkSize: Int = 128) -> [Data] {
        let fullChunks = Int(count / chunkSize)
        let totalChunks = fullChunks + (count % 1024 != 0 ? 1 : 0)

        var chunks = [Data]()
        for chunkCounter in 0 ..< totalChunks {
            var chunk: Data
            let chunkBase = chunkCounter * chunkSize
            var diff = chunkSize
            if chunkCounter == totalChunks - 1 {
                diff = count - chunkBase
            }

            let range: Range<Data.Index> = chunkBase ..< (chunkBase + diff)
            chunk = subdata(in: range)

            chunks.append(chunk)
        }

        return chunks
    }
}
