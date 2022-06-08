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
    
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
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
@available(macOS 10.15.0, *)
@available(iOS 13.0, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method without any body parameter. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    public func fetchItems(urlLink: URL?) async throws -> NetworkResult<Data> {
        guard let url = urlLink else {
            throw URLError(.badURL)
        }
        
        let request = URLRequest(url: url)
        
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
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItems<D: Decodable>(urlLink: URL?, _ model: D.Type) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItems(urlLink: urlLink)
            
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
     
     - Throws: An `URLError` is thrown if urlLink is nil or not a valied `URL` or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
     - Returns: Returns a  ``NetworkResult``
     */
    public func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?) async throws -> NetworkResult<Data> {
        guard let url = urlLink else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        
        if let valiedBody = body {
            request.httpBody = valiedBody
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
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, _ model: D.Type) async -> Result<NetworkResult<D>, Error> {
        do {
            let reply = try await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: body)
            
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
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?, httpMethod: HTTPMethod, body: E) async throws -> NetworkResult<Data> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        let reply = try await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData)
        
        return reply
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses swift concurrency.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - model: Generic Type `D` where `D` confirms to `Decodable`.
     
     - Returns: Returns a  `Result<Success, Failure>` type where `Success` is  ``NetworkResult`` and failure is `Error`
     */
    public func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?, httpMethod: HTTPMethod, body: E, _ model: D.Type) async -> Result<NetworkResult<D>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        let reply = await fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, D.self)
        
        return reply
    }
}

//MARK: With Combine Publisher
@available(macOS 10.15.0, *)
@available(iOS 13.0, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    public func fetchItems(urlLink: URL?) -> AnyPublisher<NetworkResult<Data>, Error> {
        guard let url = urlLink else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        let request = URLRequest(url: url)
        
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
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where `Success` is ``NetworkResult`` `Failure` is `Error`
     */
    public func fetchItems<D: Decodable>(urlLink: URL?, _ model: D.Type) -> AnyPublisher<NetworkResult<D>, Error> {
        return fetchItems(urlLink: urlLink)
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
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    public func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?) -> AnyPublisher<NetworkResult<Data>, Error> {
        guard let url = urlLink else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        
        if let valiedBody = body {
            request.httpBody = valiedBody
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
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: Data?,
                                                     _ model: D.Type) -> AnyPublisher<NetworkResult<D>, Error> {
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: body)
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
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    public func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: E) -> AnyPublisher<NetworkResult<Data>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data. Uses Combine Publisher.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - model: Generic Type `D` where `D` confirms to `Decodable`
     
     - Returns: Returns a  `AnyPublisher<Success, Failure>` where Success is ``NetworkResult`` Failure is `Error`
     */
    public func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                                   httpMethod: HTTPMethod,
                                                                   body: E,
                                                                   _ model: D.Type) -> AnyPublisher<NetworkResult<D>, Error> {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        return fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, D.self)
    }
}

@available(iOS 9.0, *)
@available(macOS 10.10, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItems(urlLink: URL?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
        guard let url = urlLink else {
            completion(.failure(URLError(.badURL)))
            
            return
        }
        let request = URLRequest(url: url)
        
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
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItems<D: Decodable>(urlLink: URL?,
                                         _ model: D.Type,
                                         _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void ){
        fetchItems(urlLink: urlLink) { result in
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
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void ){
        guard let url = urlLink else {
            completion(.failure(URLError(.badURL)))
            
            return
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod.rawValue
        
        if let valiedBody = body {
            request.httpBody = valiedBody
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
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod<D: Decodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: Data?,
                                                     _ model: D.Type,
                                                     _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: body) { result in
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
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod<E: Encodable>(urlLink: URL?,
                                                     httpMethod: HTTPMethod,
                                                     body: E,
                                                     _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, completion)
    }
    
    /**
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. And decodes the data with provided `Decodable` model. It's extreamly handy if anyone just  want to provide a data model and url and get back the decoded data.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>` aka `URL?`
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Generic Type `E` where `E` confirms to `Encodable`.
        - model: Generic Type `D` where `D` confirms to `Decodable`
        - completion: An `@escaping` closure parameter which provides a `Result<Success, Failure>` where `Success` is ``NetworkResult`` and `Failure` is `Error` as return of closure
     */
    public func fetchItemsByHTTPMethod<D: Decodable, E: Encodable>(urlLink: URL?,
                                                                   httpMethod: HTTPMethod,
                                                                   body: E,
                                                                   _ model: D.Type,
                                                                   _ completion: @escaping (Result<NetworkResult<D>, Error>)-> Void) {
        let uploadData = RKAPIHelper.generateRequestBody(body)
        
        fetchItemsByHTTPMethod(urlLink: urlLink, httpMethod: httpMethod, body: uploadData, D.self, completion)
    }
}
