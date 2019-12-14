//
//  Extension+UIImageView.swift
//  FidelityUmsuka
//
//  Created by Kathiresan on 11/12/19.
//  Copyright © 2019 Kathiresan. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    /// Extension to load image from url async.
    ///
    /// - Parameter urlString: URL String of image.
    public func imageFromURL(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        MediaManager.shared.downloadImage(url: url, completion: { (image) in
            DispatchQueue.main.async {
                self.image = image
            }
        }) { (errorLog) in
            if let log = errorLog {
                print(log)
            }
        }
    }
}
