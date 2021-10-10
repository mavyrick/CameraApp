//
//  SavePhotoService.swift
//  CameraApp
//
//  Created by Josh Sorokin on 08/10/2021.
//

import Foundation
import UIKit

class SavePhotoToFilesService: SavePhotoServiceProtocol {
    
    func savePhoto(image: UIImage) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("photosFolder")
        
        if !FileManager.default.fileExists(atPath: path.absoluteString) {
            try! FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        }
        
        if let data = image.jpegData(compressionQuality: 1.0) {
            
            let filename = getDocumentsDirectory().appendingPathComponent("photosFolder").appendingPathComponent("\(UUID().uuidString).jpg")
            try? data.write(to: filename)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
