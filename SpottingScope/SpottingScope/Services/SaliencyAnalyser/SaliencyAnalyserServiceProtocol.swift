//
//  SaliencyAnalyserServiceProtocol.swift
//  SpottingScope
//
//  Created by Vittcal Neestackich on 2.06.22.
//

import UIKit

protocol SaliencyAnalyserServiceProtocol {
    func getSaliencyCoordinates(for image: UIImage) -> SaliencyCoordinates
}
