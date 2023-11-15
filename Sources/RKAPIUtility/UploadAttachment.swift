//
//  
//
//  Created by Rakibur Khan on 17/6/23.
//

import Foundation

@_spi(RKAH) public struct UploadAttachment {
    let key: String
    let filename: String
    let data: Data
    let mimeType: String
    
    public init?(data: Data?, forKey key: String, fileName: String, type mimeType: String) {
        self.key = key
        self.mimeType = mimeType
        self.filename = fileName
        guard let data = data else { return nil }
        self.data = data
    }
    
    public init?(data: Data?, forKey key: String, json: Bool) {
        self.key = key
        self.mimeType = json ? ContentType.urlEncoded.value : ""
        self.filename = ""
        guard let data = data else { return nil }
        self.data = data
    }
}
