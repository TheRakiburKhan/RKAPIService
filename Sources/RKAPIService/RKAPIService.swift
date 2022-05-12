import Foundation

public class RKAPIService: RKAPIServiceProtocol {
    
    public static var shared = RKAPIService(sessionConfiguration: URLSessionConfiguration.default, delegate: nil, queue: nil)
    
    private let session: URLSession
    
    public init(sessionConfiguration: URLSessionConfiguration, delegate: URLSessionDelegate?, queue: OperationQueue?) {
        
        session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: queue)
    }
    
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
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
        
        guard let status = HTTPStatusCode(rawValue: response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return NetworkResult(data: rawData, response: status)
    }
    
    @available(macOS 10.15.0, *)
    @available(iOS 13.0, *)
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
        
        guard let status = HTTPStatusCode(rawValue: response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return NetworkResult(data: rawData, response: status)
    }
    
    @available(iOS 8.0, *)
    @available(macOS 10.10, *)
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
                
                guard let status = HTTPStatusCode(rawValue: response.statusCode) else {
                    
                    completion(.failure(URLError(.badServerResponse)))
                    
                    return
                }
                
                completion(.success(NetworkResult(data: data, response: status)))
            }
        }
        
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
