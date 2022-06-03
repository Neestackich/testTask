//
//  PhotosServiceErrors.swift
//  SpottingScope
//
//  Created by Vittcal Neestackich on 2.06.22.
//

import Foundation

enum PhotosServiceErrors: Error {
    case unauthorized
}

extension PhotosServiceErrors: LocalizedError {

    private struct Constants {
        static let unauthorizedErrorDescription = "Allow the app to get access to your photos library"
    }

    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return NSLocalizedString(Constants.unauthorizedErrorDescription, comment: "")
        }
    }

}
