//
//  SaveVideoService.swift
//  CameraApp
//
//  Created by Josh Sorokin on 08/10/2021.
//

import Foundation
import UIKit
import AVFoundation

class SaveVideoToFilesService: SaveVideoServiceProtocol {
    
    func saveVideo(videoURL: URL) {
        
        let asset = AVURLAsset(url: videoURL)
        
        if !asset.isExportable { return }
        
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            print("Failed to create export session")
            return
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let dirPath = documentsDirectory.appendingPathComponent("videosFolder")
        let outputURL = dirPath.appendingPathComponent("\(UUID().uuidString).mp4")
        print("File path: \(outputURL)")
        
        exporter.outputURL = outputURL
        exporter.outputFileType = AVFileType.mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        exporter.exportAsynchronously {
            if let error = exporter.error {
                print("Error \(error)")
            } else {
                print("Exporter completed")
            }
        }
    }
    
}
