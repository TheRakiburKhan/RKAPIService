# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [2.4.1](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/2.4.1) - 10 August 2022
### Changed
- Changed `HTTPHeader` in HTTP `GET` request from required to optional 


## [2.4.0](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/2.4.0) - 20 July 2022
### Changed
- Fixed `HTTPHeader` init issue.
### Deprecated
- Obsolated completion handler on macOS 12 and iOS 15.


## [2.3.0](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/2.3.0) - 16 June 2022
### Added
- Added `HTTPHeader` if additional headers are required.


## [2.2.2](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/2.2.2) - 08 June 2022
### Added
- Added polymorfic methods for direct data manipulation.
### Changed
- Updated Quick Help guide for methods
### Fixed
- `RKAPIHelper` methods not accessible issue solved.


## [2.2.1](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/2.2.1) - 07 June 2022
### Added
- Added `RKAPIHelper` which has helper functions to build `URL`
- `buildURL(scheme: String, baseURL: String, portNo: Int?, path: String?, queries: [URLQueryItem]?)` returns an `URL?`
- `buildURL(string: String, filter: CharacterSet)` returns an `URL?`


## [2.2.0](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/2.2.0) - 06 June 2022
### Added
- Added `URLSessionDataTaskPublisher` form `Combine` support starting form iOS 13.0 and macOS 10.15
### Changed
- Changed `RKAPIService.shared` configuration form `URLSessionConfiguration.default` to `URLSessionConfiguration.default`
- Changed all URL parsameter to optional form all `fetchItems(url:)` methods


## [2.1.0](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/2.1.0) - 21 May 2022
### Changed
- `HTTPStatusCode` will now have a status code for sure.
- Can handle custom HTTP Response codes. Previously it used to throw a generic error.


## [2.0.0](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/2.0.0) - 14 May 2022
### Changed
- Upgraded support from iOS 8 to iOS 9.
- Added dedicated get request method for iOS 9 and macOS 10.10
- Updated code documentation. Now developers can utilize the new XCode 13 `Build Documentation` feature.
- `HTTPStatusCode.ResponseType` is now *@frozen*


## [1.2.0](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/1.2.0) - 13 May 2022
### Added
- Added support for iOS 8 and MacOS 10.0 and above


## [1.0.1](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/1.0.1) - 08 May 2022
### Changed
- Network Result properties changed to public


## [1.0.0](https://github.com/TheRakiburKhan/RKAPIService/releases/tag/1.0.0) - 06 May 2022
### Added
- Initial Release
