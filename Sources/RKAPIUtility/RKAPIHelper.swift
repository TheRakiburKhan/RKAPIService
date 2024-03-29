//
//  File.swift
//  
//
//  Created by Rakibur Khan on 7/Jun/22.
//

import Foundation
/**
 RKAPIHelper provides some useful methods to help process data for network communication.
 */
public struct RKAPIHelper {
    /**
     Builds an url from given component
     
     We need `URL` if we have to  work with nework. But sometimes `URL(string:)` initializer doesn't work if url has special character or white spaces. That's why this simple url builder comes in handy
     
     - Parameters:
        - scheme: A `String` as URL Scheme. Default value is "*https*"
        - baseURL: A `String` as URL Host. Example: "*swift.org*"
        - portNo: An `Optional<Int>` aka `Int?`. Default value is *`Nil`*
        - path: An `Optional<String>` aka `String?`. Default value is *`Nil`*
        - queries: An array of `Optional<URLQueryItem>` aka `[URLQueryItem]?`. Default value is *`Nil`*
     */
    public static func buildURL(scheme: String = "https", baseURL: String, portNo: Int? = nil, path: String? = nil, queries: [URLQueryItem]? = nil)-> URL? {
        var url: URL? {
            var components = URLComponents()
            components.scheme = scheme
            components.host = baseURL
            
            if let portNo: Int = portNo {
                components.port = portNo
            }
            
            if let path = path {
                if path.first == "/" {
                    components.path = path
                } else {
                    components.path = String("/" + path)
                }
            }
            
            if let items = queries, !items.isEmpty {
                components.queryItems = items
            }
            
            return components.url
        }
        
        return url
    }
    
    /**
     Builds an url from given component
     
     We need `URL` if we have to  work with nework. But sometimes `URL(string:)` initializer doesn't work if url has special character or white spaces. That's why this modified method comes in handy.
     
     - Parameters:
        - string: An `String`
        - fillter: A `CharacterSet`. Default value is `CharacterSet.urlQueryAllowed`
     */
    @inlinable public static func buildURL(string: String, filter: CharacterSet = .urlQueryAllowed) -> URL? {
        return URL(string: string.addingPercentEncoding(withAllowedCharacters: filter) ?? "")
    }
    
    /**
     Encodes any data to `Data?` for uploding as `URLRequest` body
     
     - Parameters:
        - data: Receives generic type `T` which confirms to `Encodable`
     
     - Returns: Returns an `Optional<Data>` aka `Data?`
     */
    public static func generateRequestBody<T: Encodable>(_ data: T) -> Data? {
        return try? JSONEncoder().encode(data)
    }
    
    /**
     Encodes any data to `Data?` for uploding as `URLRequest` body
     
     - Parameters:
        - data: Receives dictionary type `[String: Any]`
     
     - Returns: Returns an `Optional<Data>` aka `Data?`
     */
    public static func generateRequestBody(_  data: [String: Any]?) -> Data? {
        guard let data = data else {return nil}

        return try? JSONSerialization.data(withJSONObject: data, options: [])
    }
    
    @_spi(RKAH) public static func generateBoundary()-> String {
        "Boundary-\(UUID().uuidString)"
    }
    
    @_spi(RKAH) public static func createDataBody(data: Data? = nil, withParameters params: [String: Any]?, media: [UploadAttachment]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let data = data {
            body = data
        }
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value)" + "\(lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                if photo.filename.isEmpty {
                    body.append("--\(boundary + lineBreak)")
                    body.append("Content-Disposition: form-data; name=\"\(photo.key)\"\(lineBreak)")
                    body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                    body.append(photo.data)
                    body.append(lineBreak)
                } else {
                    body.append("--\(boundary + lineBreak)")
                    body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                    body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                    body.append(photo.data)
                    body.append(lineBreak)
                }
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    @_spi(RKAH) public static func createDataBody(data: Data? = nil, withParameters params: [String: Any]?, media: [Attachment]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let data = data {
            body = data
        }
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value)" + "\(lineBreak)")
            }
        }
        
        if let media = media {
            for medium in media {
                let media = medium.generateAttachmentArray()
                for photo in media {
                    if photo.filename.isEmpty {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(photo.key)\"\(lineBreak)")
                        body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                        body.append(photo.data)
                        body.append(lineBreak)
                    } else {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                        body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                        body.append(photo.data)
                        body.append(lineBreak)
                    }
                }
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    @_spi(RKAH) public static func createDataBody<E: Encodable>(data: Data? = nil, withParameters type: E, media: [Attachment]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let data = data {
            body = data
        }
        
        do {
            let jsonData = try JSONEncoder().encode(type)
            
            let params = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            if let parameters = params {
                for (key, value) in parameters {
                    if let array = value as? Array<Any> {
                        for (index, value) in array.enumerated() {
                            body.append("--\(boundary + lineBreak)")
                            body.append("Content-Disposition: form-data; name=\"\(key)[\(index)]\"\(lineBreak + lineBreak)")
                            body.append("\(value)" + "\(lineBreak)")
                        }
                    } else {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                        body.append("\(value)" + "\(lineBreak)")
                    }
                }
            }
            
            if let media = media {
                for medium in media {
                    let media = medium.generateAttachmentArray()
                    for photo in media {
                        if photo.filename.isEmpty {
                            body.append("--\(boundary + lineBreak)")
                            body.append("Content-Disposition: form-data; name=\"\(photo.key)\"\(lineBreak)")
                            body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                            body.append(photo.data)
                            body.append(lineBreak)
                        } else {
                            body.append("--\(boundary + lineBreak)")
                            body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                            body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                            body.append(photo.data)
                            body.append(lineBreak)
                        }
                    }
                }
            }
            
            body.append("--\(boundary)--\(lineBreak)")
            
            return body
        } catch {
            return body
        }
    }
}

@_spi(RKAH) extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
public extension RKAPIHelper {
    /**
     Encodes any data to `Data?` for uploding as `URLRequest` body
     
     - Parameters:
        - data: Receives generic type `T` which confirms to `Encodable`
     
     - Returns: Returns an `Optional<Data>` aka `Data?`
     */
    static func generateRequestBody<D: Encodable>(_ data: D) async -> Data? {
        do {
            let reply = try JSONEncoder().encode(data)
            
            return reply
        } catch {
            return nil
        }
    }
    
    /**
     Encodes any data to `Data?` for uploding as `URLRequest` body
     
     - Parameters:
        - data: Receives dictionary type `[String: Any]`
     
     - Returns: Returns an `Optional<Data>` aka `Data?`
     */
    static func generateRequestBody(_  data: [String: Any]?) async -> Data? {
        guard let data = data else {return nil}

        return try? JSONSerialization.data(withJSONObject: data, options: [])
    }
    
    @_spi(RKAH) static func generateBoundary() async -> String {
        "Boundary-\(UUID().uuidString)"
    }
    
    @_spi(RKAH) static func createDataBody(data: Data? = nil, withParameters params: [String: Any]?, media: [UploadAttachment]?, boundary: String) async -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let data = data {
            body = data
        }
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value)" + "\(lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                if photo.filename.isEmpty {
                    body.append("--\(boundary + lineBreak)")
                    body.append("Content-Disposition: form-data; name=\"\(photo.key)\"\(lineBreak)")
                    body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                    body.append(photo.data)
                    body.append(lineBreak)
                } else {
                    body.append("--\(boundary + lineBreak)")
                    body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                    body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                    body.append(photo.data)
                    body.append(lineBreak)
                }
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    @_spi(RKAH) static func createDataBody<E: Encodable>(data: Data? = nil, withParameters type: E, media: [UploadAttachment]?, boundary: String) async -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let data = data {
            body = data
        }
        
        do {
            let jsonData = try JSONEncoder().encode(type)
            
            let params = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            if let parameters = params {
                for (key, value) in parameters {
                    if let array = value as? Array<Any> {
                        for (index, value) in array.enumerated() {
                            body.append("--\(boundary + lineBreak)")
                            body.append("Content-Disposition: form-data; name=\"\(key)[\(index)]\"\(lineBreak + lineBreak)")
                            body.append("\(value)" + "\(lineBreak)")
                        }
                    } else {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                        body.append("\(value)" + "\(lineBreak)")
                    }
                }
            }
            
            if let media = media {
                for photo in media {
                    if photo.filename.isEmpty {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(photo.key)\"\(lineBreak)")
                        body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                        body.append(photo.data)
                        body.append(lineBreak)
                    } else {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                        body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                        body.append(photo.data)
                        body.append(lineBreak)
                    }
                }
            }
            
            body.append("--\(boundary)--\(lineBreak)")
            
            return body
        } catch {
            return body
        }
    }
    
    @_spi(RKAH) static func createDataBody(data: Data? = nil, withParameters params: [String: Any]?, media: [Attachment]?, boundary: String) async -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let data = data {
            body = data
        }
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\(value)" + "\(lineBreak)")
            }
        }
        
        if let media = media {
            for medium in media {
                let media = await medium.generateAttachmentArray()
                for photo in media {
                    if photo.filename.isEmpty {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(photo.key)\"\(lineBreak)")
                        body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                        body.append(photo.data)
                        body.append(lineBreak)
                    } else {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                        body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                        body.append(photo.data)
                        body.append(lineBreak)
                    }
                }
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        
        return body
    }
    
    @_spi(RKAH) static func createDataBody<E: Encodable>(data: Data? = nil, withParameters type: E, media: [Attachment]?, boundary: String) async -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let data = data {
            body = data
        }
        
        do {
            let jsonData = try JSONEncoder().encode(type)
            
            let params = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
            
            if let parameters = params {
                for (key, value) in parameters {
                    if let array = value as? Array<Any> {
                        for (index, value) in array.enumerated() {
                            body.append("--\(boundary + lineBreak)")
                            body.append("Content-Disposition: form-data; name=\"\(key)[\(index)]\"\(lineBreak + lineBreak)")
                            body.append("\(value)" + "\(lineBreak)")
                        }
                    } else {
                        body.append("--\(boundary + lineBreak)")
                        body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                        body.append("\(value)" + "\(lineBreak)")
                    }
                }
            }
            
            if let media = media {
                for medium in media {
                    let media = await medium.generateAttachmentArray()
                    for photo in media {
                        if photo.filename.isEmpty {
                            body.append("--\(boundary + lineBreak)")
                            body.append("Content-Disposition: form-data; name=\"\(photo.key)\"\(lineBreak)")
                            body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                            body.append(photo.data)
                            body.append(lineBreak)
                        } else {
                            body.append("--\(boundary + lineBreak)")
                            body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.filename)\"\(lineBreak)")
                            body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                            body.append(photo.data)
                            body.append(lineBreak)
                        }
                    }
                }
            }
            
            body.append("--\(boundary)--\(lineBreak)")
            
            return body
        } catch {
            return body
        }
    }
}
