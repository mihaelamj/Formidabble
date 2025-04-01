import Foundation
import CryptoKit
import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
public typealias PlatformImage = NSImage
#endif

public actor ImageCache {
    public static let shared = ImageCache()

    private let fileManager = FileManager.default
    private let cacheDirectory: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let folder = base.appendingPathComponent("ThumbnailCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder
    }()

    static func cacheKey(for url: URL, width: CGFloat, height: CGFloat) -> String {
        let string = "\(url.absoluteString)_\(Int(width))x\(Int(height))"
        let hash = Insecure.MD5.hash(data: Data(string.utf8))
        return hash.map { String(format: "%02hhx", $0) }.joined() + ".image"
    }

    func imageData(forKey key: String) -> Data? {
        let path = cacheDirectory.appendingPathComponent(key)
        return try? Data(contentsOf: path)
    }

    func store(imageData: Data, forKey key: String) {
        let path = cacheDirectory.appendingPathComponent(key)
        try? imageData.write(to: path)
    }

    func path(forKey key: String) -> URL {
        cacheDirectory.appendingPathComponent(key)
    }

    public func platformImage(from data: Data) -> PlatformImage? {
        #if canImport(UIKit)
        return UIImage(data: data)
        #elseif canImport(AppKit)
        return NSImage(data: data)
        #else
        return nil
        #endif
    }

    public func loadCached(for url: URL, width: CGFloat, height: CGFloat) -> PlatformImage? {
        let key = Self.cacheKey(for: url, width: width, height: height)
        guard let data = imageData(forKey: key) else { return nil }
        return platformImage(from: data)
    }

    public func cacheImageData(from url: URL, width: CGFloat, height: CGFloat) async {
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return }
        if platformImage(from: data) != nil {
            let key = Self.cacheKey(for: url, width: width, height: height)
            store(imageData: data, forKey: key)
        }
    }
    
    public func platformImage(for url: URL, width: CGFloat, height: CGFloat) async -> Image? {
        guard let native = await loadCached(for: url, width: width, height: height) else {
            return nil
        }

        #if canImport(UIKit)
        return Image(uiImage: native)
        #elseif canImport(AppKit)
        return Image(nsImage: native)
        #else
        return nil
        #endif
    }
}
