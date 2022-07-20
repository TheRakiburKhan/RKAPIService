import Foundation
import Combine

/**
 RKAPIService class. It implements `RKAPIServiceProtocol`. This class serves all the necessary steps to perform a `URLSession` call.
 */
public class RKAPIService: RKAPIServiceProtocol {
    
    /// Static instance of `RKAPIService`. It has `URLSessionConfiguration.ephemeral` as configuration. `URLSessionDelegate` and `OperationQueue` are both nil.
    public static var shared = RKAPIService(sessionConfiguration: URLSessionConfiguration.ephemeral, delegate: nil, queue: nil)
    
    private let session: URLSession
    
    /**
     Initializes ``RKAPIService``
     
     - Parameters:
        - sessionConfiguration: Receives `URLSessionConfiguration` from `Foundation`
        - delegate: Receives an `Optional<URLSessionDelegate>` or `URLSessionDelegate?` from `Foundation`
        - queue: Receiives an `Optional<OperationQueue>` or `OperationQueue?` from `Foundation`
     */
    public init(sessionConfiguration: URLSessionConfiguration, delegate: URLSessionDelegate?, queue: OperationQueue?) {
        
        session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: queue)
    }
    
    /**
     Invalidate current session and cancel it.
     */
    public func invalidateAndCancelSession() {
        session.invalidateAndCancel()
    }
    
    @available(iOS 13.0, macOS 10.15.0, *)
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

//MARK: With async/await
@available(iOS 13.0, macOS 10.15.0, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    public func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]?) async throws -> NetworkResult<Data> {
        guard let url = urlLink else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        if let headers = additionalHeader, !headers.isEmpty {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        var rawData: Data?
        var rawResponse: URLResponse?
        
        if #available(macOS 12.0, *), #available(iOS 15.0, *){
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
     
     Fetch items with HTTP Get method without any body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses async/await concurrency of iOS 13.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItems<D: Decodable>(urlLink: URL?, additionalHeader: [HTTPHeader]? = nil, _ model: D.Type) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItems(urlLink: urlLink, additionalHeader: additionalHeader)
            
            guard let rawData = reply.data else {throw reply.response}
            
            let decodedData = try JSONDecoder().decode(model.self, from: rawData)
            
            return .success(NetworkResult(data: decodedData, response: reply.response))
        } catch {
            return .failure(error)
        }
    }
    
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
    public func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]? = nil) async throws -> NetworkResult<Data> {
        guard let url = urlLink else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        
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
        
        if #available(macOS 12.0, *), #available(iOS 15.0, *){
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
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]? = nil, _ model: D.Type) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader)
            
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
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?, httpMethod: HTTPMethod, body: E, additionalHeader: [HTTPHeader]? = nil) async throws -> NetworkResult<Data> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        let reply = try await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader)
        
        return reply
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`.
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?, httpMethod: HTTPMethod, body: E, additionalHeader: [HTTPHeader]? = nil, _ model: D.Type) async -> Result<NetworkResult<D>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        let reply = await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self)
        
        return reply
    }
}

//MARK: With Combine Publisher
@available(iOS 13.0, macOS 10.15.0, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    public func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]? = nil) -> AnyPublisher<NetworkResult<Data>, Error> {
        guard let url = urlLink else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        if let headers = additionalHeader, !headers.isEmpty {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
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
     
     Fetch items with HTTP Get method without any body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    public func fetchItems<D: Decodable>(urlLink: URL?, additionalHeader: [HTTPHeader]? = nil, _ model: D.Type) -> AnyPublisher<NetworkResult<D>, Error> {
        return fetchItems(urlLink: urlLink, additionalHeader: additionalHeader)
            .tryMap{ reply in
                guard let rawData = reply.data else {throw reply.response}
                
                let decodedData = try JSONDecoder().decode(model.self, from: rawData)
                
                return NetworkResult(data: decodedData, response: reply.response)
            }
            .mapError{ error in
                
                return error
            }
            .eraseToAnyPublisher()
    }
    
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
    public func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]? = nil) -> AnyPublisher<NetworkResult<Data>, Error> {
        guard let url = urlLink else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        
        if let valiedBody = body {
            request.httpBody = valiedBody
        }
        
        if let headers = additionalHeader, !headers.isEmpty {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
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
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: `Optional<Data>` aka `Data?` for sending to remote server.
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: Data?,
                                                     additionalHeader: [HTTPHeader]? = nil,
                                                     _ model: D.Type) -> AnyPublisher<NetworkResult<D>, Error> {
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader)
            .tryMap{ reply in
                guard let rawData = reply.data else {throw reply.response}
                
                let decodedData = try JSONDecoder().decode(model.self, from: rawData)
                
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
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    public func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: E,
                                                     additionalHeader: [HTTPHeader]? = nil) -> AnyPublisher<NetworkResult<Data>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    public func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                                   httpMethod: HTTPMethod,
                                                                   body: E,
                                                                   additionalHeader: [HTTPHeader]? = nil,
                                                                   _ model: D.Type) -> AnyPublisher<NetworkResult<D>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self)
    }
}

@available(iOS, deprecated: 13.0, obsoleted: 15.0, message: "Completion handler may occur memory leak, user async/await or Combine Publisher instead")
@available(macOS, deprecated: 10.15.0, obsoleted: 12.0, message: "Completion handler may occur memory leak, user async/await or Combine Publisher instead")
extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]? = nil, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
        guard let url = urlLink else {
            completion(.failure(URLError(.badURL)))
            
            return
        }
        
        var request = URLRequest(url: url)
        
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
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItems<D: Decodable>(urlLink: URL?,
                                         additionalHeader: [HTTPHeader]? = nil,
                                         _ model: D.Type,
                                         _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void ){
        fetchItems(urlLink: urlLink, additionalHeader: additionalHeader) { result in
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
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]? = nil, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
        guard let url = urlLink else {
            completion(.failure(URLError(.badURL)))
            
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        
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
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: Data?,
                                                     additionalHeader: [HTTPHeader]? = nil,
                                                     _ model: D.Type,
                                                     _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: body, additionalHeader: additionalHeader) { result in
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
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: E,
                                                     additionalHeader: [HTTPHeader]? = nil,
                                                     _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, completion)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - additionalHeader: Receives an `Optional<Array<HTTPHeader>>` aka [``HTTPHeader``]?
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                                   httpMethod: HTTPMethod,
                                                                   body: E,
                                                                   additionalHeader: [HTTPHeader]? = nil,
                                                                   _ model: D.Type,
                                                                   _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, additionalHeader: additionalHeader, D.self, completion)
    }
}
