//
//  File.swift
//  
//
//  Created by Rakibur Khan on 2/May/22.
//

import Foundation

public struct NetworkResult<T> {
    public let data: T?
    public let response: HTTPStatusCode
    
    init(data: T? = nil, response: HTTPStatusCode) {
        self.data = data
        self.response = response
    }
}
