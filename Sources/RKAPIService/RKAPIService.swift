import Foundation
@_spi(RKAH) import RKAPIUtility

/**
 RKAPIService class. This class serves all the necessary steps to perform a `URLSession` call.
 */
public class RKAPIService {
    
    /// Static instance of `RKAPIService`. It has `URLSessionConfiguration.ephemeral` as configuration. `URLSessionDelegate` and `OperationQueue` are both nil.
    public static var shared = RKAPIService()
    
    internal var session: URLSession
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
                } else {
                    if let data = data, let response = response {
                        continuation.resume(with: .success((data, response)))
                    }
                }
            }
        })
    }
    
    internal func legacyUploadTask(request: URLRequest, data: Data) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
            session.uploadTask(with: request, from: data) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    if let data = data, let response = response {
                        continuation.resume(with: .success((data, response)))
                    }
                }
            }
        })
    }
    
    internal func legacyUploadTask(request: URLRequest, fileURL: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
            session.uploadTask(with: request, fromFile: fileURL) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    if let data = data, let response = response {
                        continuation.resume(with: .success((data, response)))
                    }
                }
            }
        })
    }
    
    @available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
    internal func legacyUploadTask(request: URLRequest, data: Data) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(Data, URLResponse), Error>) in
            session.uploadTask(with: request, from: data) { data, response, error in
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
