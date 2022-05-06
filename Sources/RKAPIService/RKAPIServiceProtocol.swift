//
//  File.swift
//  
//
//  Created by Rakibur Khan on 1/May/22.
//

import Foundation

/**
 Protocol for communication with remote server for data transfer  and receive
 */
public protocol RKAPIServiceProtocol {
    /**
     Fetch items with HTTP Get method without any body parameter. Uses asyn/await method of iOS 15
     
     - Parameters:
     - urlLink: Receives an optional URL
     
     - Throws: An URLError is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also HTTPStatusCode Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult<T>`` where T is raw Data
     
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItems(urlLink: URL?) async throws -> NetworkResult<Data>
    
    
    /**
     Fetch items with HTTP method with body parameter. Uses asyn/await method of iOS 15
     
     - Parameters:
     - urlLink: Receives an optional URL
     - httpMethod: HTTPMethod enum value to send data with that specific method.
     - body: Optional raw Data for sending to remote server.
     - jsonData: Accepts a boolean value to determine if HTTP body is in JSON format
     
     - Throws: An URLError is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also HTTPStatusCode Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult<T>`` where T is raw Data
     
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?) async throws -> NetworkResult<Data>
}
