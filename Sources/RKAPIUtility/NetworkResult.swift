//
//  NetworkResult.swift
//  
//
//  Created by Rakibur Khan on 2/May/22.
//

import Foundation

/**
 This structure is used to hold `HTTP` request response and data. It receives a generic optional paramenter for data.
 It receives a generic paramenter *`T`* as type of data which is `Optional` type. It receives ``HTTPStatusCode`` as response.
 */
public struct NetworkResult<T> {
    public let data: T?
    public let response: HTTPURLResponse
    public let statusCode: HTTPStatusCode
    
    /**
     Initialization
     - Parameters:
        - data: Receives an optional value
        - response: `HTTPURLResponse` class
        - statusCode: `HTTPStatusCode` enum value to send data with that specific method.
     */
    public init(data: T? = nil, response: HTTPURLResponse, statusCode: HTTPStatusCode) {
        self.data = data
        self.response = response
        self.statusCode = statusCode
    }
}

extension NetworkResult: Sendable where T: Sendable {}
