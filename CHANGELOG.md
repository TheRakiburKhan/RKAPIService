Version 2.4.0
- Fixed `HTTPHeader` init issue.
- Obsolated completion handler on macOS 12 and iOS 15.

Version 2.3.0
- Added `HTTPHeader` if additional headers are required.

Version 2.2.2
- Updated Quick Help guide for methods
- Added polymorfic methods for direct data manipulation.
- `RKAPIHelper` methods not accessible issue solved.

Version 2.2.1

- Added `RKAPIHelper` which has helper functions to build `URL`
- `buildURL(scheme: String, baseURL: String, portNo: Int?, path: String?, queries: [URLQueryItem]?)` returns an `URL?`
- `buildURL(string: String, filter: CharacterSet)` returns an `URL?`

Version 2.2.0

- Changed `RKAPIService.shared` configuration form `URLSessionConfiguration.default` to `URLSessionConfiguration.default`
- Changed all URL parsameter to optional form all `fetchItems(url:)` methods
- Added `URLSessionDataTaskPublisher` form `Combine` support starting form iOS 13.0 and macOS 10.15

Version 2.1.0

- `HTTPStatusCode` will now have a status code for sure.
- Can handle custom HTTP Response codes. Previously it used to throw a generic error.

Version 2.0.0

- Upgraded support from iOS 8 to iOS 9.
- Added dedicated get request method for iOS 9 and macOS 10.10
- Updated code documentation. Now developers can utilize the new XCode 13 `Build Documentation` feature.
- `HTTPStatusCode.ResponseType` is now *@frozen*

Version 1.2.0

Added support for iOS 8 and MacOS 10.0 and above

Version 1.0.1

Network Result properties changed to public

Version 1.0.0

Initial Release
