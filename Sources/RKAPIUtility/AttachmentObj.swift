//
//  
//
//  Created by Rakibur Khan on 19/6/23.
//

import Foundation

public struct AttachmentObj {
    public let key: String
    public let fileArray: [AttachmentFileModel]
    public let fileItem: AttachmentFileModel?
    
    public init?(file: AttachmentFileModel?, forKey key: String) {
        self.key = key
        guard let file = file else {return nil}
        self.fileItem = file
        self.fileArray = []
    }
    
    public init?(files: [AttachmentFileModel], forKey key: String) {
        self.key = key
        self.fileItem = nil
        guard !files.isEmpty else {return nil}
        self.fileArray = files
    }
}

#if canImport(UIKit)
import UIKit

@available(iOS 13.0, macOS 10.15.0, watchOS 6.0, tvOS 13.0, *)
extension AttachmentObj {
    func generateAttachmentArray() async -> [Attachment] {
        var attachmets: [Attachment] = []
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
    
    func generateAttachment(item: AttachmentFileModel, key: String) async -> Attachment? {
        .init(data: item.file, forKey: key, fileName: item.fileName, type: item.mimeType)
    }
}
#endif
