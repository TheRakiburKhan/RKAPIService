//
//  
//
//  Created by Rakibur Khan on 17/6/23.
//

import Foundation
@_spi(RKAH) import RKAPIUtility

//MARK: - Base methods
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
     - request: Receives an `URLRequest`
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItemsWithRequest(request: URLRequest) async throws -> NetworkResult<Data> {
        var rawData: Data?
        var rawResponse: URLResponse?
        
        if #available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *) {
            (rawData, rawResponse) = try await session.data(for: request)
        }
        else {
            (rawData, rawResponse) = try await previousVersionURLSession(request: request)
        }
        
        guard let response = rawResponse as? HTTPURLResponse else {
            
            throw URLError(.cannotParseResponse)
        }
        
        let status = HTTPStatusCode(rawValue: response.statusCode)
        
        return NetworkResult(data: rawData, response: status)
    }
    
    //MARK: - Original fetchItems
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy`
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItemsBase(urlLink: URL?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> NetworkResult<Data> {
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
        
        return try await fetchItemsWithRequest(request: request)
    }
    
    //MARK: - Original fetchItemsByHTTPMethod
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied `URL` or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItemsByHTTPMethodBase(urlLink: URL?, httpMethod: HTTPMethod, body: Data? = nil, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> NetworkResult<Data> {
        guard let url = urlLink else {
            throw URLError(.badURL)
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
        
        return try await fetchItemsWithRequest(request: request)
    }
}

//MARK: - Public Methods

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
    func fetchItems(request: URLRequest) async throws -> NetworkResult<Data> {
        try await fetchItemsWithRequest(request: request)
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
                    cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> NetworkResult<Data> {
        try await fetchItemsBase(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     Fetch items with HTTP Get method without any body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses async/await concurrency of iOS 13.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    func fetchItems<D: Decodable>(urlLink: URL?,
                                  additionalHeader: [Header]? = nil,
                                  _ model: D.Type,
                                  cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItemsBase(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try JSONDecoder().decode(model.self, from: rawData)
            
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
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItems<D: Decodable>(request: URLRequest, _ model: D.Type) async throws -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItemsWithRequest(request: request)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try JSONDecoder().decode(model.self, from: rawData)
            
            return .success(NetworkResult(data: decodedData, response: reply.response))
        } catch {
            return .failure(error)
        }
    }
}

//MARK: - All Requests
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
public extension RKAPIService {
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied `URL` or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItemsByHTTPMethod(urlLink: URL?,
                                httpMethod: HTTPMethod,
                                body: Data? = nil,
                                additionalHeader: [Header]? = nil,
                                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> NetworkResult<Data> {
        
        return try await fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied `URL` or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Encodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: D,
                                              additionalHeader: [Header]? = nil,
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> NetworkResult<Data> {
        let uploadData = await RKAPIHelper.generateRequestBody(body)
        return try await fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: Data? = nil,
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type,
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try JSONDecoder().decode(model.self, from: rawData)
            
            return .success(NetworkResult(data: decodedData, response: reply.response))
        } catch {
            return .failure(error)
        }
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - model: Generic Type `D` where `D` confirms to `Decodable`.
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                            httpMethod: HTTPMethod,
                                                            body: E,
                                                            additionalHeader: [Header]? = nil,
                                                            _ model: D.Type,
                                                            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error> {
        let uploadData = await RKAPIHelper.generateRequestBody(body)
        return await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, cachePolicy: cachePolicy)
    }
    
    //MARK: fetchItemsByHTTPMethod [String: Any]
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `[String: Any]` aka `[String: Any]` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied `URL` or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a ``NetworkResult``
     */
    func fetchItemsByHTTPMethod(urlLink: URL?,
                                httpMethod: HTTPMethod,
                                body: [String: Any],
                                additionalHeader: [Header]? = nil,
                                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> NetworkResult<Data> {
        let uploadData = await RKAPIHelper.generateRequestBody(body)
        
        return try await fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `[String: Any]` aka `[String: Any]` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: [String: Any],
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error> {
        let uploadData = await RKAPIHelper.generateRequestBody(body)
        
        return await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, cachePolicy: cachePolicy)
    }
}

//MARK: - All Requests with attachment
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
public extension RKAPIService {
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
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied `URL` or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult`
     */
    func fetchItemsByHTTPMethod(urlLink: URL?,
                                httpMethod: HTTPMethod,
                                body: [String: Any]? = nil,
                                multipartAttachment: [Attachment],
                                additionalHeader: [Header]? = nil,
                                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> NetworkResult<Data>{
        let boundary = await RKAPIHelper.generateBoundary()
        
        let data = await RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        return try await fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: [ContentType.formData(boundary: boundary)], cachePolicy: cachePolicy)
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
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: [String: Any]? = nil,
                                              multipartAttachment: [Attachment],
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type,
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error>{
        let boundary = await RKAPIHelper.generateBoundary()
        
        let data = await RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        return await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, model.self, cachePolicy: cachePolicy)
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
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied `URL` or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: E,
                                              multipartAttachment: [Attachment],
                                              additionalHeader: [Header]? = nil,
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> NetworkResult<Data>{
        let boundary = await RKAPIHelper.generateBoundary()
        
        let data = await RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        return try await fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, cachePolicy: cachePolicy)
        
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
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                            httpMethod: HTTPMethod,
                                                            body: E,
                                                            multipartAttachment: [Attachment],
                                                            additionalHeader: [Header]? = nil,
                                                            _ model: D.Type,
                                                            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error>{
        let boundary = await RKAPIHelper.generateBoundary()
        
        let data = await RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        return await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, model.self, cachePolicy: cachePolicy)
    }
}
