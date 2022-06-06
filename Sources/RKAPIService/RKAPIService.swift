import Foundation
import Combine

/**
 RKAPIService class. It implements `RKAPIServiceProtocol`. This class serves all the necessary steps to perform a `URLSession` call.
 */
public class RKAPIService: RKAPIServiceProtocol {
    
    /// Static instance of `RKAPIService`. It has ``URLSessionConfiguration.ephemeral`` as configuration. ``URLSessionDelegate`` and ``OperationQueue`` are both nil.
    public static var shared = RKAPIService(sessionConfiguration: URLSessionConfiguration.ephemeral, delegate: nil, queue: nil)
    
    private let session: URLSession
    
    /**
     Initializes ``RKAPIService``
     
     - Parameters:
        - sessionConfiguration: Receives ``URLSessionConfiguration`` from ``Foundation``
        - delegate: Receives an ``Optional<URLSessionDelegate>`` or ``URLSessionDelegate?`` from ``Foundation``
        - queue: Receiives an ``Optional<OperationQueue>`` or ``OperationQueue?`` from ``Foundation``
     */
    public init(sessionConfiguration: URLSessionConfiguration, delegate: URLSessionDelegate?, queue: OperationQueue?) {
        
        session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: queue)
    }
    
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
     Fetch items with HTTP Get method without any body parameter. Uses async/await concurrency of iOS 13
     
     - Parameters:
        - urlLink: Receives an ``Optional<URL>``
     
     - Throws: An ``URLError`` is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
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
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses asyn/await method of iOS 13
     - Parameters:
        - urlLink: Receives an optional URL
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Optional raw Data for sending to remote server.
        - jsonData: Accepts a boolean value to determine if HTTP body is in JSON format
     
     - Throws: An URLError is thrown if urlLink is nil or not a valied URL or server does not provide any response. Also ``HTTPStatusCode`` Error (Custom error) can be thrown if server status code is anything but 200...299
     
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
}

//MARK: With Combine Publisher
@available(macOS 10.15.0, *)
@available(iOS 13.0, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses async/await concurrency of iOS 13.
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>`
     
     - Returns: Returns a  ``AnyPublisher<Success, Failure>`` where `Success` is ``NetworkResult`` `Failure` is ``Error``
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
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses asyn/await method of iOS 13.
     
     - Parameters:
        - urlLink: Receives an optional URL
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Optional raw Data for sending to remote server.
        - jsonData: Accepts a boolean value to determine if HTTP body is in JSON format
     
     - Returns: Returns a  ``AnyPublisher<Success, Failure>`` where Success is ``NetworkResult`` Failure is ``Error``
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
}

@available(iOS 9.0, *)
@available(macOS 10.10, *)
extension RKAPIService {
    /**
     Fetch items with HTTP Get method.
     
     Fetch items with HTTP Get method without any body parameter. Uses async/await concurrency of iOS 13
     
     - Parameters:
        - urlLink: Receives an `Optional<URL>`
        - completion: An `@escaping` closure parameter which provides a ``Result<Success, Failure>`` where `Success` is ``NetworkResult`` and `Failure` is ``Error`` as return of closure
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
     Fetch items with HTTP method.
     
     Fetch items with HTTP method with body parameter. Uses asyn/await method of iOS 13.
     
     - Parameters:
        - urlLink: Receives an optional URL
        - httpMethod: ``HTTPMethod`` enum value to send data with that specific method.
        - body: Optional raw Data for sending to remote server.
        - jsonData: Accepts a boolean value to determine if HTTP body is in JSON format
        - completion: An `@escaping` closure parameter which provides a ``Result<Success, Failure>`` where `Success` is ``NetworkResult`` and `Failure` is ``Error`` as return of closure
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
}
