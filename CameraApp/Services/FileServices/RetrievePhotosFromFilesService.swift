//
//  RetreiveVideosFromFilesService.swift
//  CameraApp
//
//  Created by Josh Sorokin on 08/10/2021.
//

import Foundation
import UIKit

class RetrievePhotosFromFilesService: RetrievePhotosServiceProtocol {
    
    func retrievePhotos(completion: @escaping ([Photo]) -> ()) {
        
        var photos: [Photo] = []
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent("photosFolder"), includingPropertiesForKeys: nil)
            
            for url in fileURLs {
                let attributes =
                    try FileManager.default.attributesOfItem(atPath: (url.path))
                let creationDate = attributes[.creationDate]
                
                photos.append(Photo(photo: UIImage(contentsOfFile: url.path)!, thumbnail:  UIImage(contentsOfFile: url.path)!.resized(withPercentage: 0.2)!, timestamp: creationDate as! Date))
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        completion(photos)
    }
    
}
