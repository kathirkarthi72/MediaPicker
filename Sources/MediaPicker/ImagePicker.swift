//
//  MediaManager.swift
//
//
//  Created by Kathiresan on 14/12/19.
//  Updated by Kathiresan on 04/10/20.

import Foundation
import UIKit
import Photos

/// Picked Image
public struct PickedImage {
    public var image: UIImage?
    public var filePath: URL?
    public var api: String?
}

/// Image picker
open class ImagePicker: NSObject {
    
    public typealias ImagePickerHandler = ((_ selected: PickedImage) -> ())
    
    public static let shared: ImagePicker = ImagePicker()
    
    private weak var presentationController: UIViewController?
    
    let pickerController: UIImagePickerController = UIImagePickerController()
    
    public var apiKey: String?
    
    private var handler: ImagePickerHandler? = nil
    
    private func requestAccess() {
        DispatchQueue.main.async {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                    
                    switch status {
                    case .authorized, .limited:
                        self.presentOptions()
                    case .denied, .notDetermined, .restricted:
                        DispatchQueue.main.async {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        }
                    @unknown default:
                        fatalError()
                    }
                }
            } else {
                // Fallback on earlier versions
                self.presentOptions()
            }
        }
    }
    
    private func presentOptions() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            if let action = self.action(for: .camera, title: "Take photo") {
                alertController.addAction(action)
            }
            if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
                alertController.addAction(action)
            }
            if let action = self.action(for: .photoLibrary, title: "Photo library") {
                alertController.addAction(action)
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            //            if UIDevice.current.userInterfaceIdiom == .pad {
            //                alertController.popoverPresentationController?.sourceView = sourceView
            //                alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            //                alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
            //            }
            self.presentationController?.present(alertController, animated: true)
        }
        
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { (action) in
            
            DispatchQueue.main.async {
                
                self.pickerController.mediaTypes = ["public.image"]
                self.pickerController.sourceType = type
                self.pickerController.delegate = self
                
                self.presentationController?.present(self.pickerController, animated: true, completion: {
                })
                
            }
        }
    }
    
    /// Present source view
    /// - Parameter sourceView: view
    public func present(presentationController: UIViewController, completed: ImagePickerHandler? = nil) {
        
        self.handler = completed
        
        self.presentationController = presentationController
        // self.delegate = delegate
        
        self.requestAccess()
    }
    
    private func pickerController(didSelect image: UIImage?, imageURL: URL?) {
        
        pickerController.dismiss(animated: true, completion: nil)
        // self.delegate?.imagePicker(picker: self, didSelected: image, apikey: apiKey)
        
        handler?(PickedImage(image: image, filePath: imageURL, api: apiKey))
    }
}

/// ImagePicker controller delegate
extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(didSelect: nil, imageURL: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if #available(iOS 11.0, *) {
            self.pickerController(didSelect: info[.originalImage] as? UIImage, imageURL: info[.imageURL] as? URL)
        } else {
            // Fallback on earlier versions
            self.pickerController(didSelect: info[.originalImage] as? UIImage, imageURL: info[.referenceURL] as? URL)
        }
    }
}
