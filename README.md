# RKAPIService
![Platforms Support](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-blue) ![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-blue) ![Swift Version](https://img.shields.io/badge/Swift-5-red) ![iOS Version](https://img.shields.io/badge/iOS-9-blue) ![macOS Version](https://img.shields.io/badge/macOS-10.10-blue) ![XCode Version](https://img.shields.io/badge/XCode-9-blue)

`RKAPIService` uses Combine publishers or Swift's native concurrency *"async/await"*  and performs simple Restful API operations. Apple offers `URLSession` async/await API's only above *iOS 15.0* and *macOS 12.0* but swift concurrency is supported from *iOS 13.0* and *macOS 10.15*. `RKAPIService` let's developer utilize those `URLSession` *async/await* operations down to *iOS 13.0* or *macOS 10.15*

***N.B: Currently we support `URLSession.dataTask` only. Rest is coming soon.***

## Table of Contents

- [System Requirments](#system-requirments)
- [Installations](#installations)
- [Usage](#usages)
- - [For iOS 13.0+ and macOS 10.15+](#for-ios-130-and-macos-1015)
- - [For iOS 9.0+ and macOS 10.10+](#for-ios-90-and-macos-1010)
- [Author](#author)
- [Lisence](#license)
- [Changelog](#changelog)

## System Requirments

RKAPIService requires 

- iOS 9.0 or above
- macOS 10.10 or above
- XCode 9.0 or above

## Installations

RKAPIService is available through [Swift Package Manager](https://swift.org/package-manager/). To install
it, simply follow the steps:

1. In Xcode, select File > Swift Packages > Add Package Dependency.
1. Follow the prompts using the URL for this repository
1. Select the `RKAPIService`-prefixed libraries you want to use

## Usage

### For iOS 13.0+ and macOS 10.15+

- Import `RKAPIService` 

- Create and instance of `RKAPIService`. Developer can also use the *shared* instance by typing `RKAPIService.shared`

- Use `func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?) async throws -> NetworkResult<Data>` for calling any `URLSession.dataTask` operations. This is a *Throwing* method.

- Use `func fetchItemsByHTTPMethod(urlLink: URL?, httpMethod: HTTPMethod, body: Data?) -> AnyPublisher<NetworkResult<Data>, Error>` for calling any `URLSession.dataTask` operations via `Combine` Publishers. This is non *Throwing* method.

- If the developer want's to do simple *HTTP GET* request then there is another dedicated API for that,
`func fetchItems(urlLink: URL?) async throws -> NetworkResult<Data>`. This is a *Throwing* method.

If the developer want's to do simple *HTTP GET* request then there is another dedicated API for that, `func fetchItems(urlLink: URL?) -> AnyPublisher<NetworkResult<Data>, Error>`. This is non *Throwing* method.

#### Example with async/await

``` Swift
import Foundation
import RKAPIService

final class DataFetchService {
    let apiService = RKAPIService.shared
    
    //If you want to use any type of HTTP Request
    func fetchDataWithBody(url: URL?, method: HTTPMethod, body: Data?) async {
        do {
            let reply = try await apiService.fetchItemsByHTTPMethod(urlLink: url, httpMethod: method, body: body)
            
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
    func fetchData(url: URL?)async {
        do {
            let reply = try await apiService.fetchItems(urlLink: url)
            
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
    func fetchDataWithBody(url: URL?, method: HTTPMethod, body: Data?) {
        apiService.fetchItemsByHTTPMethod(urlLink: url, httpMethod: method, body: body)
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
    func fetchData(url: URL?)async {
        apiService.fetchItems(urlLink: url)
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

### For iOS 9.0+ and macOS 10.10+

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
    func fetchDataWithBody(url: URL?, method: HTTPMethod, body: Data?) {
        apiService.fetchItemsByHTTPMethod(urlLink: url, httpMethod: method, body: body) { result in
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
    func fetchData(url: URL?) {
         apiService.fetchItems(urlLink: url) { result in
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

## Author

Rakibur Khan, contact me via [email](mailto:therakiburkhan@gmail.com) or visit my [website](http://therakiburkhan.me)

## License

This package is licensed under MIT License. See the [LICENSE](LICENSE.md) file.

## Changelog

All changes are loggedd in [CHANGELOG](CHANGELOG.md) file.