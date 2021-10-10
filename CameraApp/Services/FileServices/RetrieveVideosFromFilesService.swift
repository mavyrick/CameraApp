//
//  RetrieveVideosFromFilesService.swift
//  CameraApp
//
//  Created by Josh Sorokin on 08/10/2021.
//

import Foundation
import UIKit
import AVFoundation

class RetrieveVideosFromFilesService: RetrieveVideosServiceProtocol {
    
    func retrieveVideos(completion: @escaping ([Video]) -> ()) {
        
        var videos: [Video] = []
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL.appendingPathComponent("videosFolder"), includingPropertiesForKeys: nil)
            
            for url in fileURLs {
                
                let attributes =
                    try FileManager.default.attributesOfItem(atPath: (url.path))
                let creationDate = attributes[.creationDate]
                
                let thumbnail = getThumbnailImageFromVideoUrl(url: url)
                
                videos.append(Video(video: url, thumbnail: thumbnail, timestamp: creationDate as! Date))
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        completion(videos)
    }
    
    // This should be on another queue but I couldn't get it working without getting nil values.
    func getThumbnailImageFromVideoUrl(url: URL) -> UIImage {
        // DispatchQueue.global().async {
        let asset = AVAsset(url: url)
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        let thumnailTime = CMTimeMake(value: 2, timescale: 1)
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
            let thumbImage = UIImage(cgImage: cgThumbImage)
            // DispatchQueue.main.async {
            return thumbImage
            // completion(thumbImage)
            // }
        } catch {
            print(error.localizedDescription)
            // DispatchQueue.main.async {
            return UIImage()
            // }
        }
        // }
    }
    
}
