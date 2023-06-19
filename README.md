# RKAPIService

[![Coding time tracker](https://wakatime.com/badge/github/TheRakiburKhan/RKAPIService.svg)](https://wakatime.com/badge/github/TheRakiburKhan/RKAPIService)
![Platforms Support](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-blue)
![License](https://img.shields.io/badge/License-MIT-blue)
![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-green)
![Cocoapod](https://img.shields.io/badge/pod-Incompatible-red)
![Carthage](https://img.shields.io/badge/carthage-Incompatible-red)
![Swift Version](https://img.shields.io/badge/Swift-5-red)
![iOS Version](https://img.shields.io/badge/iOS-11-blue)
![macOS Version](https://img.shields.io/badge/macOS-10.13-blue)
![watchOS Version](https://img.shields.io/badge/watchOS-4-blue)
![tvOS Version](https://img.shields.io/badge/tvOS-11-blue)

`RKAPIService` uses Combine publishers or Swift's native concurrency *"async/await"*  and performs simple Restful API operations. Apple offers `URLSession` async/await API's only above *iOS 15.0*, *macOS 12.0*, *watchOS 8.0* and *tvOS 15.0* but swift concurrency is supported from *iOS 13.0*, *macOS 10.15*, *watchOS 6.0* and *tvOS 13.0*. `RKAPIService` let's developer utilize those `URLSession` *async/await* operations down to *iOS 13.0*, *macOS 10.15*, *watchOS 6.0* or *tvOS 13.0*

***N.B: Currently we support `URLSession.dataTask` only. Rest is coming soon.***

## Table of Contents

- [System Requirments](#system-requirments)
- [Installations](#installations)
- [Usage](#usages)
    - [For iOS 13.0+, macOS 10.15+, watchOS 6.0+ or tvOS 13.0+](#for-iOS-1300,macOS-1015,watchOS-6000-or-tvOS-1300)
    - [For iOS 11.0+ and macOS 10.13+](#for-ios-110-and-macos-1013)
- [Helper](#helper)
- [Author](#author)
- [Lisence](#license)
- [Changelog](#changelog)

## System Requirments

RKAPIService requires 

- iOS 11.0 or above
- macOS 10.13 or above
- watchOS 4.0 or above
- tvOS 11.0 or above
- XCode 12.0 or above

## Installations

RKAPIService is available through [Swift Package Manager](https://swift.org/package-manager/). To install
it, simply follow the steps:

- In Xcode, select File > Swift Packages > Add Package Dependency.
- Follow the prompts using the URL for this repository
```
https://github.com/TheRakiburKhan/RKAPIService.git
```
- Select the `RKAPIService` - prefixed libraries you want to use

#### OR
Add as a package dependency 
``` Swift
.package(url: "https://github.com/TheRakiburKhan/RKAPIService.git", from: "3.0.0")
```

## Usage

### For iOS 13.0+, macOS 10.15+, watchOS 6.0+ or tvOS 13.0+

- Import `RKAPIService` 

- Create and instance of `RKAPIService`. Developer can also use the *shared* instance by typing `RKAPIService.shared`

- Use `func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?) async throws -> NetworkResult<Data>` for calling any `URLSession.dataTask` operations. This is a *Throwing* method.

- Use `func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?) -> AnyPublisher<NetworkResult<Data>, Error>` for calling any `URLSession.dataTask` operations via `Combine` Publishers. This is non *Throwing* method.

- If the developer want's to do simple *HTTP GET* request then there is another dedicated API for that,
`func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]?) async throws -> NetworkResult<Data>`. This is a *Throwing* method.

If the developer want's to do simple *HTTP GET* request then there is another dedicated API for that, `func fetchItems(urlLink: URL?, additionalHeader: [HTTPHeader]?) -> AnyPublisher<NetworkResult<Data>, Error>`. This is non *Throwing* method.

#### Example with async/await

``` Swift
import Foundation
import RKAPIService

final class DataFetchService {
    let apiService = RKAPIService.shared
    
    //If you want to use any type of HTTP Request
    func fetchDataWithBody(url: URL?, method: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?) async {
        do {
            let reply = try await apiService.fetchItemsByHTTPMethod(urlLink: url, httpMethod: method, body: body, additionalHeader: additionalHeader)
            
            //Handle your data and response code however you like

            //Printing Optional<Data>
            debugPrint(reply.data)

            //Printing HTTPStatusCode
            debugPrint(reply.response)

        } catch(let error) {
            // Handle any exception or Error
        }
    }

    // If you want to use HTTP Get Request only
    func fetchData(url: URL?, additionalHeader: [HTTPHeader]?) async {
        do {
            let reply = try await apiService.fetchItems(urlLink: url, additionalHeader: additionalHeader)
            
            //Handle your data and response code however you like

            //Printing Optional<Data>
            debugPrint(reply.data)

            //Printing HTTPStatusCode
            debugPrint(reply.response)

        } catch(let error) {
            // Handle any exception or Error
        }
    }
}
```

#### Example with Combine Publisher

``` Swift
import Foundation
import Combine
import RKAPIService

final class DataFetchService {
    let apiService = RKAPIService.shared
    let cancellable = Set<AnyCancellable>()
    
    //If you want to use any type of HTTP Request
    func fetchDataWithBody(url: URL?, method: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?) {
        apiService.fetchItemsByHTTPMethod(urlLink: url, httpMethod: method, body: body, additionalHeader: additionalHeader)
        //Receiving on Main Thread
            .receive(on: DispatchQueue.main)
            .sink { reply in
                switch reply {
                    case .finished:
                        // After finishing a successful call
                        break
                    case .failure(let error):
                        // Handle any exception or Error
                        break
                }
            } receiveValue: { result in
                //Handle your data and response code however you like
                
                //Printing Optional<Data>
                debugPrint(result.data)
                
                //Printing HTTPStatusCode
                debugPrint(result.response)
            }
        
    }
    
    // If you want to use HTTP Get Request only
    func fetchData(url: URL?, additionalHeader: [HTTPHeader]?) {
        apiService.fetchItems(urlLink: url, additionalHeader: additionalHeader)
        //Receiving on Main Thread
            .receive(on: DispatchQueue.main)
            .sink { reply in
                switch reply {
                    case .finished:
                        // After finishing a successful call
                        break
                    case .failure(let error):
                        // Handle any exception or Error
                        break
                }
            } receiveValue: { result in
                //Handle your data and response code however you like
                
                //Printing Optional<Data>
                debugPrint(result.data)
                
                //Printing HTTPStatusCode
                debugPrint(result.response)
            }
    }
}

```

### For iOS 11.0+ and macOS 10.10+

- Import `RKAPIService` 

- Create and instance of `RKAPIService`. Developer can also use the *shared* instance by typing `RKAPIService.shared`

- Use `func fetchItems(urlLink: URL?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void )` for calling any `URLSession.dataTask` operations. This is a *Throwing* method

- If the developer want's to do simple *HTTP GET* request then there is another dedicated API for that,
`func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?, _ completion: @escaping (Result<NetworkResult<Data>, Error>)-> Void )`
#### Example

``` Swift
import Foundation
import RKAPIService

final class DataFetchService {
    let apiService = RKAPIService.shared
    
    //If you want to use any type of HTTP Request
    func fetchDataWithBody(url: URL?, method: HTTPMethod, body: Data?, additionalHeader: [HTTPHeader]?) {
        apiService.fetchItemsByHTTPMethod(urlLink: url, httpMethod: method, body: body, additionalHeader: additionalHeader) { result in
            switch result {
                case .success(let reply):
                    //Handle your data and response code however you like
                    
                    //Printing Optional<Data>
                    debugPrint(reply.data)
                    
                    //Printing HTTPStatusCode
                    debugPrint(reply.response)
                    
                case .failure(let error):
                    // Handle any exception or Error
                    debugPrint(error)
                    
            }
        }
    }

    // If you want to use HTTP Get Request only
    func fetchData(url: URL?, additionalHeader: [HTTPHeader]?) {
         apiService.fetchItems(urlLink: url, additionalHeader: additionalHeader) { result in
            switch result {
                case .success(let reply):
                    //Handle your data and response code however you like
                    
                    //Printing Optional<Data>
                    debugPrint(reply.data)
                    
                    //Printing HTTPStatusCode
                    debugPrint(reply.response)
                    
                case .failure(let error):
                    // Handle any exception or Error
                    debugPrint(error)
                    
            }
        }
    }
}
```
## Helper
When working with network communication, `URL` is the primary component. A simple URLBuilder is included with this package to build `URL` properly and effortlessly.
- `buildURL(scheme: String, baseURL: String, portNo: Int?, path: String?, queries: [URLQueryItem]?)` returns an `URL?`
- `buildURL(string: String, filter: CharacterSet)` returns an `URL?`

#### Example
Here is an exapmple of building simple url of  [Swift Pacakge Manager](https://swift.org/package-manager) page link.
``` Swift
RKAPIHelper.buildURL(scheme: "https", baseURL: "swift.org", portNo: nil, path: "/package-manager", queries: nil)

RKAPIHelper.buildURL(string: "https://swift.org/package-manager", filter: .urlQueryAllowed)
```

## Author

Rakibur Khan, contact me via [email](mailto:therakiburkhan@gmail.com) or visit my [website](http://therakiburkhan.me)

## License

This package is licensed under MIT License. See the [LICENSE](LICENSE) file.

## Changelog

All changes are loggedd in [CHANGELOG](CHANGELOG.md) file.
