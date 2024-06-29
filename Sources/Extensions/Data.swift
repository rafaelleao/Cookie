import Foundation

@available(macOS 10.15, *)
public extension Data {
    private static let bufferSize = 1024

    init(reading input: InputStream) {
        self.init()

        input.open()
        defer {
            input.close()
        }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Data.bufferSize)
        defer {
            buffer.deallocate()
        }

        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: Data.bufferSize)
            append(buffer, count: read)
        }
    }

    func toJson() -> Any? {
        let jsonObject = try? JSONSerialization.jsonObject(with: self, options: .allowFragments)
        return jsonObject
    }

    func toJsonString() -> String? {
        guard let jsonObject = toJson() else {
            return nil
        }
        return prettyPrintedJSONObject(jsonObject)
    }

    func toString(encoding: String.Encoding = .utf8) -> String? {
        let str = String(data: self, encoding: encoding)
        return str?.removingPercentEncoding
    }

    private func prettyPrintedJSONObject(_ jsonObject: Any) -> String? {
        let options: JSONSerialization.WritingOptions = [.prettyPrinted, .withoutEscapingSlashes]
        guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: options),
              let jsonString = prettyJsonData.toString()
        else {
            return nil
        }
        return jsonString
    }
}
