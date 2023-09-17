//
//  File.swift
//  
//
//  Created by Rakibur Khan on 19/6/23.
//

import Foundation

public struct AttachedFile {
    public let file: Data?
    
    public let fileName: String
    
    public let mimeType: String
    
    public init(file: Data?, fileName: String, mimeType: String) {
        self.file = file
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

#if canImport(UIKit)
import UIKit

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

public extension AttachedFile {
    @available(macCatalyst 14.0, *)
    @available(iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    init?(withImage image: UIImage?, compress: Double = 0.8, fileName: String, type: UTType = .png) {
        self.mimeType = type.preferredMIMEType ?? ""
        self.fileName = fileName+".\(type.preferredFilenameExtension ?? "")"
        
        switch type {
            case .jpeg, .bmp, .svg:
                if compress <= 1.0 {
                    guard let data = image?.jpegData(compressionQuality: compress) else { return nil }
                    self.file = data
                } else {
                    guard let data = image?.jpegData(compressionQuality: 1.0) else { return nil }
                    self.file = data
                }
                
            case .png:
                guard let data = image?.pngData() else { return nil }
                self.file = data
                
            default:
                return nil
        }
    }
    
    @available(iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    init?(withData data: Data?, fileName: String, type: UTType) {
        guard let data = data else {return nil}
        self.file = data
        self.mimeType = type.preferredMIMEType ?? ""
        self.fileName = fileName+".\(type.preferredFilenameExtension ?? "")"
    }
    
    init?(withImage image: UIImage?, fileName: String, mimeType: String) {
        self.mimeType = mimeType
        self.fileName = fileName
        guard let file = image?.pngData() else { return nil }
        self.file = file
    }
}
#endif

#if canImport(AppKit)
import AppKit

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

public extension AttachedFile {
    @available(macOS 11.0, *)
    init?(withImage image: NSImage?, fileName: String, type: UTType = .png) {
        self.mimeType = type.preferredMIMEType ?? ""
        self.fileName = fileName+".\(type.preferredFilenameExtension ?? "")"
        
        guard let cgImage = image?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        
        switch type {
            case .jpeg, .bmp, .svg:
                let imageRep = NSBitmapImageRep(cgImage: cgImage)
                guard let jpegData = imageRep.representation(using: .jpeg, properties: [:]) else { return nil }
                self.file = jpegData
                
            case .png:
                let imageRep = NSBitmapImageRep(cgImage: cgImage)
                guard let jpegData = imageRep.representation(using: .png, properties: [:]) else { return nil }
                self.file = jpegData
                
            default:
                return nil
        }
    }
    
    @available(macOS 11.0, *)
    init?(withData data: Data?, fileName: String, type: UTType = .png) {
        guard let data = data else {return nil}
        self.file = data
        self.mimeType = type.preferredMIMEType ?? ""
        self.fileName = fileName+".\(type.preferredFilenameExtension ?? "")"
    }
    
    init?(withImage image: NSImage?, fileName: String, mimeType: String) {
        self.mimeType = mimeType
        self.fileName = fileName
        
        guard let cgImage = image?.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let imageRep = NSBitmapImageRep(cgImage: cgImage)
        guard let jpegData = imageRep.representation(using: .png, properties: [:]) else { return nil }
        self.file = jpegData
    }
}
#endif
