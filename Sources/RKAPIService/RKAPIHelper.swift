//
//  File.swift
//  
//
//  Created by Rakibur Khan on 7/Jun/22.
//

import Foundation

struct RKAPIHelper {
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
    static func buildURL(scheme: String = "https", baseURL: String, portNo: Int? = nil, path: String? = nil, queries: [URLQueryItem]? = nil)-> URL? {
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
    @inlinable static func buildURL(string: String, filter: CharacterSet = .urlQueryAllowed) -> URL? {
        return URL(string: string.addingPercentEncoding(withAllowedCharacters: filter) ?? "")
    }
}
