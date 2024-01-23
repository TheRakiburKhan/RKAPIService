//
//  
//
//  Created by Rakibur Khan on 23/1/24.
//

import Foundation
@_spi(RKAH) import RKAPIUtility

@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
extension RKAPIService {
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
    func fetchItemsByHTTPMethodBase(urlLink: URL?, httpMethod: HTTPMethod, body: Data? = nil, additionalHeader: [Header]? = nil, cachePolicy: URLRequest.CachePolicy? = nil, delegate: (URLSessionTaskDelegate)? = nil) async throws -> NetworkResult<Data> {
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
        
        return try await fetchItemsWithRequest(for: request, delegate: delegate)
    }
}