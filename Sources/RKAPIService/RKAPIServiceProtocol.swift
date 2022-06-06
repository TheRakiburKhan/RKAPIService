//
//  File.swift
//  
//
//  Created by Rakibur Khan on 1/May/22.
//

import Foundation
import Combine

/**
 Protocol for communication with remote server for data transfer  and receive
 */
public protocol RKAPIServiceProtocol {
    /**
     Fetch items with HTTP Get method without any body parameter. Uses async/await concurrency of iOS 13
     
     - Parameters:
        - urlLink: Receives an optional URL
     
     - Throws: An URLError is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult<T>`` where T is raw Data
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItems(urlLink: URL?) async throws -> NetworkResult<Data>
    
    /**
     Fetch items with HTTP Get method without any body parameter. Uses async/await concurrency of iOS 13
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>`
        - completion: An `@escaping` closure parameter which provides a ``Result<NetworkResult<Data>, Error>`` as return of closure
     */
    @available(iOS 9.0, *)
    @available(macOS 10.10, *)
    func fetchItems(urlLink: URL?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void )
    
    /**
     Fetch items with HTTP method with body parameter. Uses asyn/await method of iOS 13
     
     - Parameters:
        - urlLink: Receives an optional URL
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Optional raw Data for sending to remote server.
        - jsonData: Accepts a boolean value to determine if HTTP body is in JSON format
     
     - Throws: An URLError is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult<T>`` where T is raw Data
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?) async throws -> NetworkResult<Data>
    
    /**
     Fetch items with HTTP method with body parameter. Uses asyn/await method of iOS 13
     
     - Parameters:
        - urlLink: Receives an optional URL
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Optional raw Data for sending to remote server.
        - jsonData: Accepts a boolean value to determine if HTTP body is in JSON format
        - completion: An `@escaping` closure parameter which provides a ``Result<NetworkResult<Data>, Error>`` as return of closure
     */
    @available(iOS 9.0, *)
    @available(macOS 10.10, *)
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void )
    
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses async/await concurrency of iOS 13.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>`
     
     - Returns: Returns a  ``AnyPublisher<Success, Failure>`` where `Success` is ``NetworkResult`` `Failure` is ``Error``
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItems(urlLink: URL?) -> AnyPublisher<NetworkResult<Data>, Error>
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses asyn/await method of iOS 13.
     
     - Parameters:
        - urlLink: Receives an optional URL
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Optional raw Data for sending to remote server.
        - jsonData: Accepts a boolean value to determine if HTTP body is in JSON format
     
     - Returns: Returns a  ``AnyPublisher<Success, Failure>`` where Success is ``NetworkResult`` Failure is ``Error``
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?) -> AnyPublisher<NetworkResult<Data>, Error>
}

extension RKAPIServiceProtocol {
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItems(urlLink: URL?) -> AnyPublisher<NetworkResult<Data>, Error> {
        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
    }
    
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?) -> AnyPublisher<NetworkResult<Data>, Error> {
        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
    }
    
    func fetchItems(urlLink: URL?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ) {}
    
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ) {}
}
