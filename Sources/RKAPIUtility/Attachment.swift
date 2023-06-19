//
//  
//
//  Created by Rakibur Khan on 19/6/23.
//

import Foundation

public struct Attachment {
    public let key: String
    public let fileArray: [AttachedFile]
    public let fileItem: AttachedFile?
    
    public init?(file: AttachedFile?, forKey key: String) {
        self.key = key
        guard let file = file else {return nil}
        self.fileItem = file
        self.fileArray = []
    }
    
    public init?(files: [AttachedFile], forKey key: String) {
        self.key = key
        self.fileItem = nil
        guard !files.isEmpty else {return nil}
        self.fileArray = files
    }
}

#if canImport(UIKit)
import UIKit

@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
extension Attachment {
    func generateAttachmentArray() async -> [UploadAttachment] {
        var attachmets: [UploadAttachment] = []
        if let fileItem = fileItem {
            if let attachmet = await generateAttachment(item: fileItem, key: key) {
                attachmets.append(attachmet)
            }
        } else {
            guard !fileArray.isEmpty else {return attachmets}
            
            for (index, fileItem) in fileArray.enumerated() {
                if let attachmet = await generateAttachment(item: fileItem, key: "\(key)[\(index)]") {
                    attachmets.append(attachmet)
                }
            }
        }
        
        return attachmets
    }
    
    func generateAttachment(item: AttachedFile, key: String) async -> UploadAttachment? {
        .init(data: item.file, forKey: key, fileName: item.fileName, type: item.mimeType)
    }
}
#endif
