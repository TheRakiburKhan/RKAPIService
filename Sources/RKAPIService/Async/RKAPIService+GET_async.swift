//
//  
//
//  Created by Rakibur Khan on 23/1/24.
//

import Foundation
@_spi(RKAH) import RKAPIUtility

//MARK: - Original fetchItems
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
     - urlLink: Receives an `Optional<URL>` aka `URL?`
     - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
     - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy`
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItemsBase(urlLink: URL?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil, delegate: (URLSessionTaskDelegate)? = nil) async throws -> NetworkResult<Data> {
        guard let url = urlLink else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        if let cachePolicy = cachePolicy {
            request.cachePolicy = cachePolicy
        }
        
        if let headers = additionalHeader, !headers.isEmpty {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        return try await fetchItemsWithRequest(for: request, delegate: delegate)
    }
}

//MARK: - Get Requests Only
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
public extension RKAPIService {
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
        - request: Receives an `URLRequest`
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItems(request: URLRequest, delegate: (URLSessionTaskDelegate)? = nil) async throws -> NetworkResult<Data> {
        try await fetchItemsWithRequest(for: request, delegate: delegate)
    }
    
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy`
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItems(urlLink: URL?,
                    additionalHeader: [Header]? = nil,
                    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                    delegate: (URLSessionTaskDelegate)? = nil) async throws -> NetworkResult<Data> {
        try await fetchItemsBase(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy, delegate: delegate)
    }
    
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     Fetch items with HTTP Get method without any body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses async/await concurrency of iOS 13.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    func fetchItems<D: Decodable>(urlLink: URL?,
                                  additionalHeader: [Header]? = nil,
                                  _ model: D.Type,
                                  decoder: JSONDecoder = .init(),
                                  cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                  delegate: (URLSessionTaskDelegate)? = nil) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItemsBase(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy, delegate: delegate)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try decoder.decode(model.self, from: rawData)
            
            return .success(NetworkResult(data: decodedData, response: reply.response))
        } catch {
            return .failure(error)
        }
    }
    
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
        - request: Receives an `URLRequest`
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItems<D: Decodable>(request: URLRequest, _ model: D.Type, decoder: JSONDecoder = .init(), delegate: (URLSessionTaskDelegate)? = nil) async throws -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItemsWithRequest(for: request, delegate: delegate)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try decoder.decode(model.self, from: rawData)
            
            return .success(NetworkResult(data: decodedData, response: reply.response))
        } catch {
            return .failure(error)
        }
    }
}
