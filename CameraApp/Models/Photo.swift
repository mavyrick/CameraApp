//
//  Photo.swift
//  CameraApp
//
//  Created by Josh Sorokin on 09/10/2021.
//

import UIKit

public struct Photo: MediaItem {
    
    var photo: UIImage
    var thumbnail: UIImage
    var timestamp: Date
    
    init(photo: UIImage, thumbnail: UIImage, timestamp: Date) {
        self.photo = photo
        self.thumbnail = thumbnail
        self.timestamp = timestamp
    }
    
}
