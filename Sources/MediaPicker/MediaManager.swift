//
//  File.swift
//  
//
//  Created by Kathiresan on 14/12/19.
//

import Foundation
import UIKit

// MARK: Typealias
typealias ImageCompletionHandler = (_ image: UIImage?) -> ()

typealias CompletionHandler = () -> ()
typealias FailureHandler = (_ errorLog: String?) -> ()

/// Media manager. Download and save in Document directory
struct MediaManager {
    
    /// Shared instance
    static let shared: MediaManager = {
        let mediaManager = MediaManager()
        createDirectory()
        return mediaManager
    }()
    
    /// Create directory
    fileprivate static func createDirectory() {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let folder = docDir.appendingPathComponent("media")
        
        do {
            try FileManager.default.createDirectory(atPath: folder.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            NSLog("Unable to create directory \(error.localizedDescription)")
        }
    }
    
    /// Check is Exist file
    /// - Parameter filename: file name
    fileprivate func fileIsExist(filename: String) -> Bool {
        
        let filePath = generateMediaFilePath(filename: filename)
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            return true
        } else {
            return false
        }
    }
}


// MARK: Documenting image
extension MediaManager {
    
    /// Generate file path from file name
    /// - Parameter filename: image file name
    fileprivate func generateMediaFilePath(filename: String) -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = docDir.appendingPathComponent("media/" + filename)
        
        return filePath
    }
    
    
    /// Write in document
    /// - Parameters:
    ///   - image: image
    ///   - filename: file name
    ///   - completed: completion handler
    ///   - failure: failure handler
    fileprivate func write(image: UIImage,
                           filename: String,
                           completed: @escaping CompletionHandler, failure: FailureHandler) {
        let filePath = generateMediaFilePath(filename: filename)
        
        if let data = image.jpegData(compressionQuality:  1.0) {
            
            do {
                try data.write(to: filePath)
                completed()
            } catch let error {
                failure(error.localizedDescription)
            }
        }
    }
    
    /// Read from Document
    /// - Parameter filename: file name
    fileprivate func read(filename: String) -> UIImage? {
        let filePath = generateMediaFilePath(filename: filename)
        let image = UIImage(contentsOfFile: filePath.path)
        
        return image
    }
    
    /// Download image from url
    /// - Parameters:
    ///   - url: url
    ///   - completed: completion
    ///   - failure: failure
    fileprivate func downloadImage(url: URL,
                                   completed: @escaping CompletionHandler, failure: @escaping FailureHandler) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                failure(error?.localizedDescription)
                return
            }
            
            self.write(image: image, filename: url.lastPathComponent, completed: completed, failure: failure)
        }.resume()
    }
}

// MARK: Download
extension MediaManager {
    
    /// Download image from url
    /// - Parameters:
    ///   - url: url
    ///   - completion: download image
    ///   - failure: failure
    func downloadImage(url: URL,
                       completion: @escaping ImageCompletionHandler,
                       failure: @escaping FailureHandler) {
        
        let fileName = url.lastPathComponent
        
        if fileIsExist(filename: fileName) {
            completion(read(filename: fileName))
        } else {
            
            downloadImage(url: url, completed: {
                completion(self.read(filename: fileName))
            }) { (errorLog) in
                failure(errorLog)
            }
        }
    }
}
