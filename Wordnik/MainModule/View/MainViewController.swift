//
//  MainViewController.swift
//  Wordnik
//
//  Created by User on 2/13/21.
//  Copyright © 2021 Syrym Zhursin. All rights reserved.
//

import UIKit
import Moya
import AVFoundation

class MainViewController: UIViewController {
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Type any word"
        searchBar.autocapitalizationType = .none
        searchBar.showsCancelButton = false
        searchBar.becomeFirstResponder()
        return searchBar
    }()
    
    lazy var synonymsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.48)
        layout.sectionInset = UIEdgeInsets(top: 10, left: (view.frame.width - layout.itemSize.width) / 2, bottom: 10, right: (view.frame.width - layout.itemSize.width) / 2)
        layout.minimumLineSpacing = view.frame.width - layout.itemSize.width
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.register(SynonymCollectionViewCell.self, forCellWithReuseIdentifier: "SynonymCollectionViewCell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    
    var player: AVPlayer?
    
    var presenter: MainViewPresenterProtocol!
            
    var cellInfo = WordsToDisplay()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = MainPresenter(view: self)
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        hideKeyboardWhenTappedAround()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Synonym Search"
        searchBar.delegate = self
        
        self.tabBarController?.tabBar.items![0].image = UIImage(systemName: "house")
        self.tabBarController?.tabBar.items![1].image = UIImage(systemName: "star")
        self.tabBarController?.tabBar.items![1].title = "Favourite Words"
        self.tabBarController?.tabBar.tintColor = .black
        
        let elementsUI = [searchBar, synonymsCollectionView, activityIndicator]
        elementsUI.forEach { (element) in
            self.view.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            synonymsCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 30),
            synonymsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            synonymsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            synonymsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            
            activityIndicator.centerYAnchor.constraint(equalTo: synonymsCollectionView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: synonymsCollectionView.centerXAnchor)
        ])
    }
    
    // MARK: - NETWORKING
}
extension MainViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        self.presenter.getInputText(text: searchText)
//        self.getAudio(searchText)
        searchBar.endEditing(true)
        synonymsCollectionView.reloadData()
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellInfo.synonyms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SynonymCollectionViewCell", for: indexPath) as! SynonymCollectionViewCell
        
        cell.backgroundColor = .white
        cell.synonymsWordLabel.text = cellInfo.synonyms[indexPath.row]
        cell.definitionLabel.text = cellInfo.definitionText
        cell.searchWord.text = cellInfo.searchText

        cell.favouritesButton.tag = indexPath.row
        if (cell.searchWord.text != "" && cell.searchWord.text != nil) {
            cell.playWordButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
//            cell.favouritesButton.setBackgroundImage(UIImage(systemName: likes[indexPath.row]), for: .normal)
        }
        cell.playWordButton.addTarget(self, action: #selector(playAudio1), for: .touchUpInside)
//        cell.favouritesButton.addTarget(self, action: #selector(addToFavourites(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func playAudio1() {
        guard let audio = cellInfo.soundURL, let audioURL = URL(string: audio) else {
            return
        }
        let playerItem = AVPlayerItem(url: audioURL)
        self.player = AVPlayer(playerItem: playerItem)
        player?.volume = 1.0
        player?.play()

        print("playing \(audioURL)")
    }
    
//    @objc func addToFavourites(sender: UIButton) {
//        if likes[sender.tag] == "star" {
//            likes[sender.tag] = "star.fill"
//        }
//        else {
//            likes[sender.tag] = "star"
//        }
//        sender.setBackgroundImage(UIImage(systemName: likes[sender.tag]), for: .normal)
//    }
}

extension MainViewController: MainViewProtocol {
    func playAudio(url: String) {
        cellInfo.soundURL = url
    }
    
    func showActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func setSearchText(text: String) {
        cellInfo.searchText = text
    }
    
    func setDefinition(text: String) {
        cellInfo.definitionText = text
        synonymsCollectionView.reloadData()
    }
    
    func showError(text: String) {
        let alert = UIAlertController(title: "Error", message: "\(text)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true)
        //synonymsCollectionView.reloadData()

    }
    func setSynonyms(text: [String]) {
        cellInfo.synonyms = text
        synonymsCollectionView.reloadData()
    }
}


