//
//  
//
//  Created by Rakibur Khan on 16/Jun/22.
//

import Foundation

///HTTPHeader for URLRequest
public struct HTTPHeader: Header {
    ///HTTPHeader key
    public let key: String
    
    ///HTTPHeader value
    public let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

///Header for URLRequest
 public protocol Header {
    ///Header key
    var key: String {get}
    
    ///Header value
    var value: String {get}
}

public enum Authorization: Header {
    case bearerToken(token: String)
    
    public var key: String {
        get {
            return "Authorization"
        }
    }
    
    public var value: String {
        get {
            switch self {
                case .bearerToken(let token):
                    return "Bearer \(token)"
            }
        }
    }
}

public enum ContentType: Header {
    case urlEncoded
    case rawJSON
    case formData(boundary: String)
    case plainText
    
    public var key: String {
        get {
            return "Content-Type"
        }
    }
    
    public var value: String {
        get {
            switch self {
                case .urlEncoded:
                    return "application/x-www-form-urlencoded"
                    
                case .rawJSON:
                    return "application/json"
                    
                case .formData(let boundary):
                    return "multipart/form-data; boundary=\(boundary)"
                    
                case .plainText:
                    return "text/plain; charset=UTF-8"
            }
        }
    }
}
