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

#if canImport(UIKit)
import UIKit

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

@_spi(RKAH)
extension UploadAttachment {
    @available (iOS 14.0, *)
    public init?(withImage image: UIImage?, forKey key: String, fileName: String, type: UTType = .png) {
        self.key = key
        self.mimeType = type.preferredMIMEType ?? ""
        self.filename = fileName+".\(type.preferredFilenameExtension ?? "")"
        
        switch type {
            case .jpeg:
                guard let data = image?.jpegData(compressionQuality: 0.8) else { return nil }
                self.data = data
                
            case .png:
                guard let data = image?.pngData() else { return nil }
                self.data = data
                
            default:
                return nil
        }
    }
    
    public init?(withImage image: UIImage?, forKey key: String, fileName: String, mimeType: String) {
        self.key = key
        self.mimeType = mimeType
        self.filename = fileName
        guard let data = image?.pngData() else { return nil }
        self.data = data
    }
}
#endif

#if canImport(AppKit)
import AppKit

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

extension UploadAttachment {
    @available(macOS 11.0, *)
    public init?(withImage image: NSImage?, forKey key: String, fileName: String, type: UTType = .png) {
        self.key = key
        self.mimeType = type.preferredMIMEType ?? ""
        self.filename = fileName+".\(type.preferredFilenameExtension ?? "")"
        
        guard let cgImage = image?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        switch type {
            case .jpeg:
                
                let imageRep = NSBitmapImageRep(cgImage: cgImage)
                guard let jpegData = imageRep.representation(using: .jpeg, properties: [:]) else { return nil }
                self.data = jpegData
                
            case .png:
                let imageRep = NSBitmapImageRep(cgImage: cgImage)
                guard let jpegData = imageRep.representation(using: .png, properties: [:]) else { return nil }
                self.data = jpegData
                
            default:
                return nil
        }
    }
    
    public init?(withImage image: NSImage?, forKey key: String, fileName: String, mimeType: String) {
        self.key = key
        self.mimeType = mimeType
        self.filename = fileName
        
        guard let cgImage = image?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        guard let jpegData = imageRep.representation(using: .png, properties: [:]) else { return nil }
        self.data = jpegData
    }
}
#endif
