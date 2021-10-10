//
//  MediaGridCollectionViewCell.swift
//  CameraApp
//
//  Created by Josh Sorokin on 08/10/2021.
//

import UIKit

class MediaGridCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet weak var photoIcon: UIImageView!
    @IBOutlet weak var videoIcon: UIImageView!
    
    var photo: Photo? {
        didSet {
            updatePhotoUI()
        }
    }
    
    var video: Video? {
        didSet {
            updateVideoUI()
        }
    }
    
    func updatePhotoUI() {
        imageView.image = photo?.thumbnail
        photoIcon.isHidden = false
        videoIcon.isHidden = true
    }
    
    func updateVideoUI() {
        imageView.image = video?.thumbnail
        videoIcon.isHidden = false
        photoIcon.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
}
