//
//  File.swift
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
