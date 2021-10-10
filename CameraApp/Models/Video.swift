//
//  Video.swift
//  CameraApp
//
//  Created by Josh Sorokin on 09/10/2021.
//

import Foundation
import UIKit

public struct Video: MediaItem {
    
    var video: URL
    var thumbnail: UIImage
    var timestamp: Date
    
    init(video: URL, thumbnail: UIImage, timestamp: Date) {
        self.video = video
        self.thumbnail = thumbnail
        self.timestamp = timestamp
    }
    
}
