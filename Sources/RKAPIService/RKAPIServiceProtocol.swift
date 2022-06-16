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
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    @available(iOS 9.0, *)
    @available(macOS 10.10, *)
    func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void )
    
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]?) -> AnyPublisher<NetworkResult<Data>, Error>
    
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]?) async throws -> NetworkResult<Data>
    
    /**
     Fetch items with HTTP method with body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - completion: An `@escaping` closure parameter which provides a `Result<NetworkResult<Data>, Error>` as return of closure
     */
    @available(iOS 9.0, *)
    @available(macOS 10.10, *)
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void )
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?) -> AnyPublisher<NetworkResult<Data>, Error>
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied `URL` or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?) async throws -> NetworkResult<Data>
}

@available(macOS 10.15.0, *)
@available(iOS 13.0, *)
extension RKAPIServiceProtocol {
    func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]?) -> AnyPublisher<NetworkResult<Data>, Error> {
        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
    }
    
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?) -> AnyPublisher<NetworkResult<Data>, Error> {
        return Fail(error: URLError(.unknown)).eraseToAnyPublisher()
    }
}

extension RKAPIServiceProtocol {
    func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ) {}
    
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ) {}
}
