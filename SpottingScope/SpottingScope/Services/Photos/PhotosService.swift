//
//  PhotosService.swift
//  SpottingScope
//
//  Created by Vittcal Neestackich on 2.06.22.
//

import Photos
import UIKit

final class PhotosService: PhotosServiceProtocol {

    private struct Constants {
        static let fetchLimit = 10
        static let creationDateSortKey = "creationDate"
    }

}

// MARK: - Public

extension PhotosService {

    func getUsersLibraryPhotos() -> [UIImage] {
        let assets = fetchUsersLibraryAssets()
        let images = processAssets(assets)
        return images
    }

    func askPermissionIfNeeded(completionHandler: @escaping (Result<Void, Error>) -> Void) {
        if isAuthorized() {
            completionHandler(.success(Void()))
        } else {
            requestAuthorization { result in
                switch result {
                case .success(_):
                    completionHandler(.success(Void()))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
        }
    }

}

// MARK: - Private

private extension PhotosService {

    private func isAuthorized() -> Bool {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            return true
        } else {
            return false
        }
    }

    private func requestAuthorization(completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization({ authorizationStatus in
            if authorizationStatus == .authorized {
                completionHandler(.success(true))
            } else {
                completionHandler(.failure(PhotosServiceErrors.unauthorized))
            }
        })
    }

    private func fetchUsersLibraryAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.fetchLimit = Constants.fetchLimit
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        let sortDescriptor = NSSortDescriptor(key: Constants.creationDateSortKey, ascending: false)
        options.sortDescriptors = [sortDescriptor]

        let assets = PHAsset.fetchAssets(with: .image, options: options)

        return assets
    }

    private func processAssets(_ assets: PHFetchResult<PHAsset>) -> [UIImage] {
        var images: [UIImage] = []
        let imageManager = PHCachingImageManager()

        assets.enumerateObjects ({ (object, _, _) in
            let asset = object as PHAsset
            let imageSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true
            imageManager.allowsCachingHighQualityImages = true

            imageManager.requestImage(
                for: asset,
                targetSize: imageSize,
                contentMode: .aspectFill,
                options: options,
                resultHandler: { image, _ in
                    if let image = image {
                        images.append(image)
                    }
                }
            )
        })

        return images
    }

}
