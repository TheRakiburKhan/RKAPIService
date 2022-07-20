//
//  File.swift
//  
//
//  Created by Rakibur Khan on 16/Jun/22.
//

import Foundation

///HTTPHeader for URLRequest
public struct HTTPHeader {
    ///HTTPHeader key
    let key: String
    
    ///HTTPHeader value
    let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}
