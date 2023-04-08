import Foundation
import RKAPIUtility

/**
 RKAPIService class. This class serves all the necessary steps to perform a `URLSession` call.
 */
public class RKAPIService {
    
    /// Static instance of `RKAPIService`. It has `URLSessionConfiguration.ephemeral` as configuration. `URLSessionDelegate` and `OperationQueue` are both nil.
    public static var shared = RKAPIService()
    
    private var session: URLSession
    private var config: URLSessionConfiguration
    private var delegate: URLSessionDelegate?
    private var queue: OperationQueue?
    
    /**
     Initializes ``RKAPIService``
     
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
    
    @available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
    internal func previousVersionURLSession(request: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
            session.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    if let data = data, let response = response {
                        continuation.resume(with: .success((data, response)))
                    }
                }
            }
        })
    }
}

//MARK: - With async/await
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
    public func fetchItems(urlLink: URL?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> NetworkResult<Data> {
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
        
        return try await fetchItems(request: request)
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
    public func fetchItems<D: Decodable>(urlLink: URL?,
                                         additionalHeader: [Header]? = nil,
                                         _ model: D.Type, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItems(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try JSONDecoder().decode(model.self, from: rawData)
            
            return .success(NetworkResult(data: decodedData, response: reply.response))
        } catch {
            return .failure(error)
        }
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
    public func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data? = nil, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil) async throws -> NetworkResult<Data> {
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
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: Data? = nil,
                                                     additionalHeader: [Header]? = nil,
                                                     _ model: D.Type,
                                                     cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
            
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
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: E,
                                                     additionalHeader: [Header]? = nil,
                                                     cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> NetworkResult<Data> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        let reply = try await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
        
        return reply
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
    public func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                                   httpMethod: HTTPMethod,
                                                                   body: E,
                                                                   additionalHeader: [Header]? = nil,
                                                                   _ model: D.Type,
                                                                   cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        let reply = await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, cachePolicy: cachePolicy)
        
        return reply
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
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItemsByHTTPMethod(urlLink: URL?,
                                       httpMethod: HTTPMethod,
                                       body: [String: Any],
                                       additionalHeader: [Header]? = nil,
                                       cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async throws -> NetworkResult<Data> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        let reply = try await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
        
        return reply
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
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: [String: Any],
                                                     additionalHeader: [Header]? = nil,
                                                     _ model: D.Type, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) async -> Result<NetworkResult<D>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        do {
            let reply = try await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try JSONDecoder().decode(model.self, from: rawData)
            
            return .success(NetworkResult(data: decodedData, response: reply.response))
        } catch {
            return .failure(error)
        }
    }
}

//MARK: - With URLRequest async/await
@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
        - request: Receives an `URLRequest`
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    func fetchItems(request: URLRequest) async throws -> NetworkResult<Data> {
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
            let reply = try await fetchItems(request: request)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try JSONDecoder().decode(model.self, from: rawData)
            
            return .success(NetworkResult(data: decodedData, response: reply.response))
        } catch {
            return .failure(error)
        }
    }
}

//MARK: - Completion Handller
@available(iOS, deprecated: 13.0, obsoleted: 14.8.1, message: "Completion handler may occur memory leak, use async/await instead")
@available(macOS, deprecated: 10.15.0, obsoleted: 11.6.7, message: "Completion handler may occur memory leak, use async/await instead")
@available(watchOS, deprecated: 6.0, obsoleted: 7.6.2, message: "Completion handler may occur memory leak, use async/await instead")
@available(tvOS, deprecated: 13.0, obsoleted: 14.7, message: "Completion handler may occur memory leak, use async/await instead")
extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItems(urlLink: URL?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
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
        
        fetchItems(request: request, completion)
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            else {
                
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
     
     Fetch items with HTTP Get method without any body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is `URLRequest.CachePolicy.useProtocolCachePolicy
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItems<D: Decodable>(urlLink: URL?,
                                         additionalHeader: [Header]? = nil,
                                         _ model: D.Type,
                                         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                         _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void ){
        fetchItems(urlLink: urlLink, additionalHeader: additionalHeader, cachePolicy: cachePolicy) { result in
            switch result {
                case .success(let reply):
                    do {
                        guard let rawData = reply.data else {throw reply.response}
                        
                        let decodedData = try JSONDecoder().decode(model.self, from: rawData)
                        
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
     
     Fetch items with HTTP method with body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
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
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            else {
                
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
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<Header>>` aka [``Header``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: Data?,
                                                     additionalHeader: [Header]? = nil,
                                                     _ model: D.Type,
                                                     cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                                     _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader, cachePolicy: cachePolicy) { result in
            switch result {
                case .success(let reply):
                    do {
                        guard let rawData = reply.data else {throw reply.response}
                        
                        let decodedData = try JSONDecoder().decode(model.self, from: rawData)
                        
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
    public func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: E,
                                                     additionalHeader: [Header]? = nil,
                                                     cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                                     _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, cachePolicy: cachePolicy, completion)
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
        - cachePolicy: Receives `URLRequest.CachePolicy`.  Default is ``URLRequest.CachePolicy.useProtocolCachePolicy``. Cache only works on ``HTTPMethod.get``
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                                   httpMethod: HTTPMethod,
                                                                   body: E,
                                                                   additionalHeader: [Header]? = nil,
                                                                   _ model: D.Type,
                                                                   cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                                                                   _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, cachePolicy: cachePolicy, completion)
    }
}

//MARK: - Completion Handller
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
    func fetchItems(request: URLRequest, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            else {
                
                guard let response = response as? HTTPURLResponse else {
                    completion(.failure(URLError(.cannotParseResponse)))
                    
                    return
                }
                
                let status = HTTPStatusCode(rawValue: response.statusCode)
                
                completion(.success(NetworkResult(data: data, response: status)))
            }
        }
    }
}
