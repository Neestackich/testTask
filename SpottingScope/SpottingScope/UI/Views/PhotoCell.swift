//
//  PhotoCell.swift
//  SpottingScope
//
//  Created by Vittcal Neestackich on 2.06.22.
//

import UIKit

final class PhotoCell: UICollectionViewCell {

    @IBOutlet private weak var photoImageView: UIImageView!

    func setupImage(photoImage: UIImage) {
        photoImageView.image = photoImage
    }

}
