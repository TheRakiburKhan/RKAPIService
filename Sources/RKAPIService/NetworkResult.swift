//
//  File.swift
//  
//
//  Created by Rakibur Khan on 2/May/22.
//

import UIKit

/**
 This structure is used to hold `HTTP` request response and data. It receives a generic optional paramenter for data
 
 It receives a generic paramenter *`T`* as type of data which is `Optional` type. It receives ``HTTPStatusCode`` as response.
 */
@frozen public struct NetworkResult<T> {
    public let data: T?
    public let response: HTTPStatusCode
    
    /**
     Initialization
     
     - Parameters:
        - data: Receives an optional value
        - response: ``HTTPStatusCode`` enum value to send data with that specific method.
     */
    init(data: T? = nil, response: HTTPStatusCode) {
        self.data = data
        self.response = response
    }
}
