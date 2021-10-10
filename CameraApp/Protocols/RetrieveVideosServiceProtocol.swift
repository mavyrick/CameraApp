//
//  RetrieveVideosServiceProtocol.swift
//  CameraApp
//
//  Created by Josh Sorokin on 09/10/2021.
//

protocol RetrieveVideosServiceProtocol {
  typealias RetrieveVideosCompletion = ([Video]) -> ()
  func retrieveVideos(completion: @escaping RetrieveVideosCompletion)
}
