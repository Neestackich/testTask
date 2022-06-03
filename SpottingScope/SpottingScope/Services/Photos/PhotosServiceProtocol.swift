//
//  PhotosServiceProtocol.swift
//  SpottingScope
//
//  Created by Vittcal Neestackich on 2.06.22.
//

import UIKit

protocol PhotosServiceProtocol {
    func getUsersLibraryPhotos() -> [UIImage]
    func askPermissionIfNeeded(completionHandler: @escaping (Result<Void, Error>) -> Void)
}
