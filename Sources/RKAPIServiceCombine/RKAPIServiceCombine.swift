//
//  File.swift
//  
//
//  Created by Rakibur Khan on 6/4/23.
//

import Foundation
@_spi(RKAH) import RKAPIUtility

#if canImport(Combine)
import Combine

/**
 RKAPIServiceCombine class. This class serves all the necessary steps to perform a `URLSession` call using `Combine`.
 */
public class RKAPIServiceCombine {
    
    /// Static instance of `RKAPIServiceCombine`. It has `URLSessionConfiguration.ephemeral` as configuration. `URLSessionDelegate` and `OperationQueue` are both nil.
    public static var shared = RKAPIServiceCombine()
    
    private var session: URLSession
    private var config: URLSessionConfiguration
    private var delegate: URLSessionDelegate?
    private var queue: OperationQueue?
    
    /**
     Initializes ``RKAPIServiceCombine``
     
     - Parameters:
        - sessionConfiguration: Receives `URLSessionConfiguration` from `Foundation`
        - delegate: Receives an `Optional<URLSessionDelegate>` or `URLSessionDelegate?` from `Foundation`
        - queue: Receiives an `Optional<OperationQueue>` or `OperationQueue?` from `Foundation`
     */
    public init(sessionConfiguration: URLSessionConfiguration = .ephemeral, delegate: URLSessionDelegate? = nil, queue: OperationQueue? = nil) {
        self.config = sessionConfiguration
        self.delegate = delegate
        self.queue = queue
        self.session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: queue)
    }
    
    /**
     Invalidate current session and cancel it.
     */
    public func invalidateAndCancelSession() {
        session.invalidateAndCancel()
    }
    
    /**
     Replaces the current session with a new one
     
     If at any point we need  to update our session then we call this method. If we pass the parameters then it will update session with new values. By default it will just reset the session.
     
     - Parameters:
        - sessionConfiguration: Receives `Optional<URLSessionConfiguration>` or `URLSessionConfiguration?` from `Foundation`
        - delegate: Receives an `Optional<URLSessionDelegate>` or `URLSessionDelegate?` from `Foundation`
        - queue: Receiives an `Optional<OperationQueue>` or `OperationQueue?` from `Foundation`
     */
    public func invalidateAndReinitializeSession(sessionConfiguration: URLSessionConfiguration? = nil, delegate: URLSessionDelegate? = nil, queue: OperationQueue? = nil) {
        invalidateAndCancelSession()
        
        var actualConfig: URLSessionConfiguration = self.config
        var actualDelegate: URLSessionDelegate? = self.delegate
        var actualQueue: OperationQueue? = self.queue
        
        if let sessionConfiguration = sessionConfiguration {
            actualConfig = sessionConfiguration
        }
        
        if let delegate = delegate {
            actualDelegate = delegate
        }
        
        if let queue = queue {
            actualQueue = queue
        }
        
        let newSession = URLSession(configuration: actualConfig, delegate: actualDelegate, delegateQueue: actualQueue)
        
        session = newSession
    }
}

//MARK: - Base methods
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
extension RKAPIServiceCombine {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses Combine Publisher.
     
     - Parameters:
        - request: Receives an `URLRequest`
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    func fetchItemsWithRequest(request: URLRequest)-> AnyPublisher<NetworkResult<Data>, Error> {
        return session.dataTaskPublisher(for: request)
            .mapError{ (error) -> URLError in
                
                return error
            }
            .tryMap{ output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.cannotParseResponse)
                }
                
                let status = HTTPStatusCode(rawValue: response.statusCode)
                
                return NetworkResult(data: output.data, response: status)
            }
            .eraseToAnyPublisher()
    }
    
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    func fetchItemsBase(urlLink: URL?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) -> AnyPublisher<NetworkResult<Data>, Error> {
        guard let url = urlLink else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
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
        
        return fetchItemsWithRequest(request: request)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethodBase(urlLink: URL?, httpMethod: HTTPMethod, body: Data? = nil, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) -> AnyPublisher<NetworkResult<Data>, Error> {
        guard let url = urlLink else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        
        if let cachePolicy = cachePolicy {
            request.cachePolicy = cachePolicy
        }
        
        if let valiedBody = body {
            request.httpBody = valiedBody
        }
        
        if let headers = additionalHeader, !headers.isEmpty {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        return fetchItemsWithRequest(request: request)
    }
}

//MARK: - Public Methods

//MARK: - Get Requests Only
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
public extension RKAPIServiceCombine {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses Combine Publisher.
     
     - Parameters:
     - urlLink: Receives an `Optional<URL>` aka `URL?`
     - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
     - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    func fetchItems(urlLink: URL?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) -> AnyPublisher<NetworkResult<Data>, Error> {
        
        return fetchItemsBase(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    func fetchItems<D: Decodable>(urlLink: URL?, additionalHeader: [Header]? = nil, _ model: D.Type, decoder: JSONDecoder = .init(), cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<D>, Error> {
        return fetchItemsBase(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
            .tryMap{ reply in
                guard let rawData = reply.data else {throw reply.response}
                
                let decodedData = try decoder.decode(model.self, from: rawData)
                
                return NetworkResult(data: decodedData, response: reply.response)
            }
            .mapError{ error in
                
                return error
            }
            .eraseToAnyPublisher()
    }
}

//MARK: - All Requests
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
public extension RKAPIServiceCombine {
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data? = nil, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) -> AnyPublisher<NetworkResult<Data>, Error> {
        
        return fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: Data? = nil,
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type,
                                              decoder: JSONDecoder = .init(),
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<D>, Error> {
        return fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
            .tryMap{ reply in
                guard let rawData = reply.data else {throw reply.response}
                
                let decodedData = try decoder.decode(model.self, from: rawData)
                
                return NetworkResult(data: decodedData, response: reply.response)
            }
            .mapError{ error in
                
                return error
            }
            .eraseToAnyPublisher()
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: E,
                                                     additionalHeader: [Header]? = nil,
                                                     cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<Data>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        return fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                            httpMethod: HTTPMethod,
                                                            body: E,
                                                            additionalHeader: [Header]? = nil,
                                                            _ model: D.Type,
                                                            decoder: JSONDecoder = .init(),
                                                            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<D>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, decoder: decoder, cachePolicy: cachePolicy)
    }
    
    //MARK: fetchItemsByHTTPMethod [String: Any]

    /**
     Fetch items with HTTP method.

     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.

     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `[String: Any]` aka `[String: Any]` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``

     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod(urlLink: URL?,
                                       httpMethod: HTTPMethod,
                                       body: [String: Any],
                                       additionalHeader: [Header]? = nil,
                                       cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<Data>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)

        return fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `[String: Any]` aka `[String: Any]` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: [String: Any],
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type,
                                              decoder: JSONDecoder = .init(),
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<D>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, decoder: decoder, cachePolicy: cachePolicy)
    }
}

//MARK: - All Requests with attachment
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
public extension RKAPIServiceCombine {
    /**
     Fetch items with HTTP method using multipart/formdata.
     
     Fetch items with HTTP method with body and multipart/formdata parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `[String: Any]` aka `[String: Any]` for sending to remote server.
        - multipartAttachment: Receives an array``[Attachment]``
        - additionalHeader: Receives an `Optional<Array<Header>>` aka ``[Header]``?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod(urlLink: URL?,
                                httpMethod: HTTPMethod,
                                body: [String: Any]? = nil,
                                multipartAttachment: [Attachment],
                                additionalHeader: [Header]? = nil,
                                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<Data>, Error> {
        let boundary = RKAPIHelper.generateBoundary()
        
        let data = RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        return fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: [ContentType.formData(boundary: boundary)], cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP method using multipart/formdata.
     
     Fetch items with HTTP method with body and multipart/formdata parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `[String: Any]` aka `[String: Any]` for sending to remote server.
        - multipartAttachment: Receives an array``[Attachment]``
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: [String: Any]? = nil,
                                              multipartAttachment: [Attachment],
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type,
                                              decoder: JSONDecoder = .init(),
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<D>, Error> {
        let boundary = RKAPIHelper.generateBoundary()
        
        let data = RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, model.self, decoder: decoder, cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP method using multipart/formdata.
     
     Fetch items with HTTP method with body and multipart/formdata parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - multipartAttachment: Receives an array``[Attachment]``
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: E,
                                              multipartAttachment: [Attachment],
                                              additionalHeader: [Header]? = nil,
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<Data>, Error> {
        let boundary = RKAPIHelper.generateBoundary()
        
        let data = RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        return fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, cachePolicy: cachePolicy)
        
    }
    
    /**
     Fetch items with HTTP method using multipart/formdata.
     
     Fetch items with HTTP method with body and multipart/formdata parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - multipartAttachment: Receives an array``[Attachment]``
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                            httpMethod: HTTPMethod,
                                                            body: E,
                                                            multipartAttachment: [Attachment],
                                                            additionalHeader: [Header]? = nil,
                                                            _ model: D.Type,
                                                            decoder: JSONDecoder = .init(),
                                                            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> AnyPublisher<NetworkResult<D>, Error> {
        let boundary = RKAPIHelper.generateBoundary()
        
        let data = RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, model.self, decoder: decoder, cachePolicy: cachePolicy)
    }
}
#endif
