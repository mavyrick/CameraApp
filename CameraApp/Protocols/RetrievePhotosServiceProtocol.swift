//
//  RetrievePhotosServiceProtocol.swift
//  CameraApp
//
//  Created by Josh Sorokin on 09/10/2021.
//

protocol RetrievePhotosServiceProtocol {
  typealias RetrievePhotosCompletion = ([Photo]) -> ()
  func retrievePhotos(completion: @escaping RetrievePhotosCompletion)
}
