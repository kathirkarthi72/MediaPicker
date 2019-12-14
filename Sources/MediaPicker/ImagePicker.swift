import Foundation
import UIKit

/// Image Picker delegate
public protocol ImagePickerDelegate: class {
    func imagePicker(picker: ImagePicker, didSelected image: UIImage?, apikey key: String?)
}

/// Image picker
open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    var apiKey: String?
    
    /// Image picker init
    /// - Parameters:
    ///   - presentationController: self viewcontroller
    ///   - apiKey: api key. optional
    ///   - delegate: image picker delegate
    public init(presentationController: UIViewController, apiKey: String? = nil, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.apiKey = apiKey
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    /// Present source view
    /// - Parameter sourceView: view
    public func present(from sourceView: UIView) {
        
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
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                alertController.popoverPresentationController?.sourceView = sourceView
                alertController.popoverPresentationController?.sourceRect = sourceView.bounds
                alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
            }
            self.presentationController?.present(alertController, animated: true)
        }
        
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.imagePicker(picker: self, didSelected: image, apikey: apiKey)
    }
}

/// ImagePicker controller delegate
extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {
    
}
