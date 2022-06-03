//
//  LibraryView.swift
//  SpottingScope
//
//  Created by Vittcal Neestackich on 2.06.22.
//

import UIKit

final class LibraryView: UIViewController {

    private var libraryLoadingActivityIndicator: UIActivityIndicatorView!
    private var grayView: UIView!
    private var collectionView: UICollectionView!
    private var photosService: PhotosServiceProtocol!
    private var photos: [UIImage] = []

    private struct Constants {
        static let spacing: CGFloat = 3
        static let itemFractionalWidth = 0.25
        static let itemFractionalHeight = 1.0
        static let groupFractionalWidth = 1.0
        static let groupFractionalHeight = 0.25
        static let errorTitle = "Error"
        static let cancelTitle = "Cancel"
        static let settingsTitle = "Settings"
        static let nibName = "PhotoCell"
        static let reusableCellIdentifier = "photoCell"
        static let saliencyStoryboardName = "SaliencyViewer"
        static let saliencyViewControllerName = "SaliencyViewerViewController"
        static let navbarTitle = "Recents"
        static let collectionViewBackgroundColor = UIColor.white
        static let activityIndicatorBackgroundColor = UIColor.systemGray6
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        askPermission()
    }

}

// MARK: - UICollectionViewDataSource

extension LibraryView: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.reusableCellIdentifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }

        if photos.count != 0 && photos.count > indexPath.row {
            cell.setupImage(photoImage: photos[indexPath.row])
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard : UIStoryboard = UIStoryboard(name: Constants.saliencyStoryboardName, bundle:nil)

        guard let saliencyViewerVC = storyboard.instantiateViewController(withIdentifier: Constants.saliencyViewControllerName) as? SaliencyViewerView else {
            return
        }

        if photos.count != 0 && photos.count > indexPath.row {
            let selectedPhoto = photos[indexPath.row]
            saliencyViewerVC.setImageForPreview(selectedPhoto)
        }

        self.navigationController?.pushViewController(saliencyViewerVC, animated: true)
    }

}

// MARK: - Private

private extension LibraryView {

    private func setup() {
        configurePhotosService()
        setupView()
    }

    private func setupView() {
        setupCollectionView()
        setupNavBar()
        setupActivityIndicator()
    }

    private func configurePhotosService() {
        photosService = PhotosService()
    }

    private func setupActivityIndicator() {
        libraryLoadingActivityIndicator = UIActivityIndicatorView(style: .large)
        grayView = UIView()
        grayView.backgroundColor = Constants.activityIndicatorBackgroundColor
        grayView.frame = self.view.frame
        libraryLoadingActivityIndicator.center = grayView.center
        grayView.addSubview(libraryLoadingActivityIndicator)
    }

    private func setupNavBar() {
        navigationController?.navigationBar.topItem?.title = Constants.navbarTitle
        navigationController?.navigationBar.topItem?.rightBarButtonItems = []
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = Constants.collectionViewBackgroundColor
        let nib = UINib(nibName: Constants.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: Constants.reusableCellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }

    private func createLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 3
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(Constants.itemFractionalWidth),
            heightDimension: .fractionalHeight(Constants.itemFractionalHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(Constants.groupFractionalWidth),
            heightDimension: .fractionalWidth(Constants.groupFractionalHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }

    private func askPermission() {
        showActivityIndicator(true)

        photosService.askPermissionIfNeeded { [weak self] result in
            switch result {
            case .success(_):
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let sself = self else { return }

                    sself.photos = sself.photosService.getUsersLibraryPhotos()

                    DispatchQueue.main.async {
                        sself.collectionView.reloadData()
                        sself.showActivityIndicator(false)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showSettingsAlert(title: Constants.errorTitle, message: error.localizedDescription)
                }
            }
        }
    }

    private func showSettingsAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelTitle = Constants.cancelTitle
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: nil))

        let settingsTitle = Constants.settingsTitle
        alert.addAction(UIAlertAction(title: settingsTitle, style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }))

        present(alert, animated: true, completion: nil)
    }

    private func showActivityIndicator(_ animated: Bool) {
        if animated {
            self.view.addSubview(grayView)
            libraryLoadingActivityIndicator.startAnimating()
        } else {
            grayView.removeFromSuperview()
            libraryLoadingActivityIndicator.stopAnimating()
        }
    }

}
