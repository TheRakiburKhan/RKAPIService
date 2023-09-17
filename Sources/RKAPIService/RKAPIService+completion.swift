//
//  
//
//  Created by Rakibur Khan on 16/6/23.
//

import Foundation
@_spi(RKAH) import RKAPIUtility

//MARK: - Base methods
@available(iOS, deprecated: 13.0, obsoleted: 14.8.1, message: "Completion handler may occur memory leak, use async/await instead")
@available(macOS, deprecated: 10.15.0, obsoleted: 11.6.7, message: "Completion handler may occur memory leak, use async/await instead")
@available(watchOS, deprecated: 6.0, obsoleted: 7.6.2, message: "Completion handler may occur memory leak, use async/await instead")
@available(tvOS, deprecated: 13.0, obsoleted: 14.7, message: "Completion handler may occur memory leak, use async/await instead")
extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter.
     
     - Parameters:
        - request: Receives an `URLRequest`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsWithRequest(request: URLRequest, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(URLError(.cannotParseResponse)))
                    
                    return
                }
                
                let status = HTTPStatusCode(rawValue: response.statusCode)
                
                completion(.success(NetworkResult(data: data, response: status)))
            }
        }
    }
    
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsBase(urlLink: URL?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
        guard let url = urlLink else {
            completion(.failure(URLError(.badURL)))
            
            return
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
        
        fetchItemsWithRequest(request: request, completion)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethodBase(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
        guard let url = urlLink else {
            completion(.failure(URLError(.badURL)))
            
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        request.cachePolicy = cachePolicy
        
        if let valiedBody = body {
            request.httpBody = valiedBody
        }
        
        if let headers = additionalHeader, !headers.isEmpty {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        fetchItemsWithRequest(request: request, completion)
    }
}

//MARK: - Public Methods

//MARK: - Get Requests Only

@available(iOS, deprecated: 13.0, obsoleted: 14.8.1, message: "Completion handler may occur memory leak, use async/await instead")
@available(macOS, deprecated: 10.15.0, obsoleted: 11.6.7, message: "Completion handler may occur memory leak, use async/await instead")
@available(watchOS, deprecated: 6.0, obsoleted: 7.6.2, message: "Completion handler may occur memory leak, use async/await instead")
@available(tvOS, deprecated: 13.0, obsoleted: 14.7, message: "Completion handler may occur memory leak, use async/await instead")
public extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter.
     
     - Parameters:
        - request: Receives an `URLRequest`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItems(request: URLRequest, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void) {
        fetchItemsWithRequest(request: request, completion)
    }
    
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItems(urlLink: URL?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
        fetchItemsBase(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy, completion)
    }
    
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItems<D: Decodable>(urlLink: URL?,
                                  additionalHeader: [Header]? = nil,
                                  _ model: D.Type,
                                  decoder: JSONDecoder = .init(),
                                  cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                  _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void ) {
        fetchItemsBase(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy) { result in
            switch result {
                case .success(let reply):
                    do {
                        guard let rawData = reply.data else {throw reply.response}
                        
                        let decodedData = try decoder.decode(model.self, from: rawData)
                        
                        completion(.success(NetworkResult(data: decodedData, response: reply.response)))
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
}

//MARK: - All Requests
@available(iOS, deprecated: 13.0, obsoleted: 14.8.1, message: "Completion handler may occur memory leak, use async/await instead")
@available(macOS, deprecated: 10.15.0, obsoleted: 11.6.7, message: "Completion handler may occur memory leak, use async/await instead")
@available(watchOS, deprecated: 6.0, obsoleted: 7.6.2, message: "Completion handler may occur memory leak, use async/await instead")
@available(tvOS, deprecated: 13.0, obsoleted: 14.7, message: "Completion handler may occur memory leak, use async/await instead")
public extension RKAPIService {
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
        fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader, cachePolicy: cachePolicy, completion)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: Data?,
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type,
                                              decoder: JSONDecoder = .init(),
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                              _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader, cachePolicy: cachePolicy) { result in
            switch result {
                case .success(let reply):
                    do {
                        guard let rawData = reply.data else {throw reply.response}
                        
                        let decodedData = try decoder.decode(model.self, from: rawData)
                        
                        completion(.success(NetworkResult(data: decodedData, response: reply.response)))
                    } catch {
                        completion(.failure(error))
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: E,
                                                     additionalHeader: [Header]? = nil,
                                                     cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                                     _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy, completion)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        -  decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                            httpMethod: HTTPMethod,
                                                            body: E,
                                                            additionalHeader: [Header]? = nil,
                                                            _ model: D.Type,
                                                            decoder: JSONDecoder = .init(),
                                                            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                                            _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, decoder: decoder, cachePolicy: cachePolicy, completion)
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
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod(urlLink: URL?,
                                httpMethod: HTTPMethod,
                                body: [String: Any],
                                additionalHeader: [Header]? = nil,
                                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void){
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy, completion)
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
        - decoder: `JSONDecoder` object to decode data
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: [String: Any],
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type,
                                              decoder: JSONDecoder = .init(),
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                              _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, decoder: decoder, cachePolicy: cachePolicy, completion)
    }
}

//MARK: - All Requests with attachment
@available(iOS, deprecated: 13.0, obsoleted: 14.8.1, message: "Completion handler may occur memory leak, use async/await instead")
@available(macOS, deprecated: 10.15.0, obsoleted: 11.6.7, message: "Completion handler may occur memory leak, use async/await instead")
@available(watchOS, deprecated: 6.0, obsoleted: 7.6.2, message: "Completion handler may occur memory leak, use async/await instead")
@available(tvOS, deprecated: 13.0, obsoleted: 14.7, message: "Completion handler may occur memory leak, use async/await instead")
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
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod(urlLink: URL?,
                                httpMethod: HTTPMethod,
                                body: [String: Any]? = nil,
                                multipartAttachment: [Attachment],
                                additionalHeader: [Header]? = nil,
                                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void){
        let boundary = RKAPIHelper.generateBoundary()
        
        let data = RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
       fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: [ContentType.formData(boundary: boundary)], cachePolicy: cachePolicy, completion)
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
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: [String: Any]? = nil,
                                              multipartAttachment: [Attachment],
                                              additionalHeader: [Header]? = nil,
                                              _ model: D.Type,
                                              decoder: JSONDecoder = .init(),
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                              _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        let boundary = RKAPIHelper.generateBoundary()
        
        let data = RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, model.self, decoder: decoder, cachePolicy: cachePolicy, completion)
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
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                              httpMethod: HTTPMethod,
                                              body: E,
                                              multipartAttachment: [Attachment],
                                              additionalHeader: [Header]? = nil,
                                              cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                              _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void) {
        let boundary = RKAPIHelper.generateBoundary()
        
        let data = RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        fetchItemsByHTTPMethodBase(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, cachePolicy: cachePolicy, completion)
        
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
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                            httpMethod: HTTPMethod,
                                                            body: E,
                                                            multipartAttachment: [Attachment],
                                                            additionalHeader: [Header]? = nil,
                                                            _ model: D.Type,
                                                            decoder: JSONDecoder = .init(),
                                                            cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                                            _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        let boundary = RKAPIHelper.generateBoundary()
        
        let data = RKAPIHelper.createDataBody(withParameters: body, media: multipartAttachment, boundary: boundary)
        
        var activeHeader: [Header] = []
        
        if let additionalHeader = additionalHeader {
            activeHeader = additionalHeader
        }
        
        activeHeader.append(ContentType.formData(boundary: boundary))
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: data, additionalHeader: activeHeader, model.self, decoder: decoder, cachePolicy: cachePolicy, completion)
    }
}
