//
//  
//
//  Created by Rakibur Khan on 2/May/22.
//

import Foundation

/**
 HTTP methods for rest api communication
 */
@frozen public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
    case copy = "COPY"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
}
