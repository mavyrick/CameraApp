//
//  MediaGridViewController.swift
//  CameraApp
//
//  Created by Josh Sorokin on 08/10/2021.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation
import AVKit

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

//I would normally use a ViewController and add the collection view manually. I would move the delegate methods somewhere else.
class MediaGridCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // This class is completely decoupled and injectable except for these references which are interchangable.
    let retrievePhotosService: RetrievePhotosServiceProtocol = RetrievePhotosFromFilesService()
    let retrieveVideosService: RetrieveVideosServiceProtocol = RetrieveVideosFromFilesService()
    
    //  I encountered the problem of having to downcast MediaItem to Photo or Video each time I want to access their properties. This is not very scaliable because if more types of media items are added more conditionals will have to be added throughout the application to manage the downcasts which could lead to large, unnecessary if/else statements. It would be better to implement something like this: https://www.swiftbysundell.com/questions/array-with-mixed-types/
    var mediaItems = [MediaItem]()
    
    var assetCollection: PHAssetCollection!
    var availableWidth: CGFloat = 0
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    var activityView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Album"
        
        setupActivityIndicator()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        if availableWidth != width {
            availableWidth = width
            let columnCount = (availableWidth / 80).rounded(.towardZero)
            let itemLength = (availableWidth - columnCount - 1) / columnCount
            collectionViewFlowLayout.itemSize = CGSize(width: itemLength, height: itemLength)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // I used a qos queue here so that the use does not have to wait for all the media to load before they can do other actions. I would have liked to make it so that this screen does not have to reload everthing everytime the user naviagtes to it, but did not have time to implement this.
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.fetchMedia()
        }
        
        let scale = UIScreen.main.scale
        let cellSize = collectionViewFlowLayout.itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func fetchMedia() {
        DispatchQueue.main.async {
            self.activityView.isHidden = false
        }
        
        var photos: [Photo] = []
        var videos: [Video] = []
        
        retrievePhotosService.retrievePhotos(completion: { (retrievedPhotos) -> Void in
            photos = retrievedPhotos
        })
        
        retrieveVideosService.retrieveVideos(completion: { (retrievedVideos) -> Void in
            videos = retrievedVideos
        })
        
        let unsortedMediaItems: [MediaItem] = photos + videos
        
        // Sort the media by time created
        let sortedMediaItems = unsortedMediaItems.sorted {
            $0.timestamp < $1.timestamp
        }
        
        mediaItems = sortedMediaItems
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.activityView.isHidden = true
        }
    }
    
    func setupActivityIndicator() {
        activityView.isHidden = true
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhoto" {
            let indexPath = sender as? NSIndexPath
            let vc = segue.destination as? PhotoViewController
            
            let photo = mediaItems[indexPath!.item] as! Photo
            
            vc?.photo = photo.photo
            vc?.photoIndex = indexPath?.item
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaGridViewCell", for: indexPath) as? MediaGridCollectionViewCell
        else { fatalError("Unexpected cell in collection view") }
        
// It would be better to do this without having to downcast because the if/else statements will continue to grow as new media types are added.
        if let photo = mediaItems[indexPath.item] as? Photo {
            cell.photo = photo
            
            return cell
            
        } else {
            let video = mediaItems[indexPath.item] as? Video
            
            cell.video = video
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mediaItems[indexPath.item] is Photo {
            performSegue(withIdentifier: "showPhoto", sender: indexPath)
        } else {
            
            guard let video = mediaItems[indexPath.item] as? Video else { return }
            
            let url = video.video
            
            let player = AVPlayer(url: url)
            
            // I used the built-in video player because I did not have time to build a custom one.
            let controller = AVPlayerViewController()
            controller.player = player
            
            present(controller, animated: true) {
                player.play()
            }
        }
    }
    
}
