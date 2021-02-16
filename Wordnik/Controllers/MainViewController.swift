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
    
    var likes: [String] = []
    
    var player: AVPlayer?
        
    let provider = MoyaProvider<APIService>()
    
    var wordsToDisplay = WordsToDisplay()
        
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func getSynonyms(_ text: String) {
        activityIndicator.startAnimating()
        provider.request(.getSynonyms(text: text)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let wordnikResponse = try JSONDecoder().decode([WordnikResponse].self, from: response.data)
                    guard let synonyms = wordnikResponse.first?.words else {
                        return
                    }
                    self?.wordsToDisplay.synonyms = synonyms
                    self?.wordsToDisplay.searchText = text
                    self?.likes = [String](repeating: "star", count: self?.wordsToDisplay.synonyms.count ?? 0)
                    self?.synonymsCollectionView.reloadData()
                    print(self?.wordsToDisplay.synonyms ?? "")
                    
                } catch let error {
                    let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self?.present(alert, animated: true)
                    self?.wordsToDisplay.searchText = ""
                    self?.likes = []
                    self?.wordsToDisplay.synonyms = []

                    self?.synonymsCollectionView.reloadData()
                    
                    print("Parsing error: \(error.localizedDescription)")
                }
            case .failure(let error):
                let requestError = error as NSError
                print("Request error: \(requestError.localizedDescription), code: \(requestError.code)")
            }
            self?.activityIndicator.stopAnimating()

        }
    }
    private func getDefinition(_ text: String) {
        provider.request(.getDefinition(text: text)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    let data = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String : Any]]
                    guard let definition = data?.first?["text"] as? String else {
                        self?.wordsToDisplay.definitionText = ""

                        print("Cannot find this word's definition")
                        return
                    }
                    self?.wordsToDisplay.definitionText = definition
                    print("def: - ", definition)
                    self?.synonymsCollectionView.reloadData()
                } catch let error {
                    print("Error parsing: \(error.localizedDescription)")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func getAudio(_ text: String) {
        provider.request(.getAudio(text: text)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
                    guard let jsonData = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String : Any]], let audioURL = jsonData.first?["fileUrl"] as? String else {
                        return
                    }
                    self?.wordsToDisplay.soundURL = audioURL
                    print("audio data - \(audioURL)")
                } catch let error {
                    print(error.localizedDescription)
                }
                
            case .failure(let error):
                print("getAudio error: \(error.localizedDescription)")
            }
        }
    }

}
extension MainViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        self.getSynonyms(searchText)
        self.getDefinition(searchText)
        self.getAudio(searchText)
        searchBar.endEditing(true)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsToDisplay.synonyms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SynonymCollectionViewCell", for: indexPath) as! SynonymCollectionViewCell
        
        cell.backgroundColor = .white
        cell.synonymsWordLabel.text = wordsToDisplay.synonyms[indexPath.row]
        cell.searchWord.text = wordsToDisplay.searchText
        cell.definitionLabel.text = wordsToDisplay.definitionText
        cell.favouritesButton.tag = indexPath.row
        if (cell.searchWord.text != "" && cell.searchWord.text != nil) {
            cell.playWordButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
            cell.favouritesButton.setBackgroundImage(UIImage(systemName: likes[indexPath.row]), for: .normal)
        }
        cell.playWordButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        cell.favouritesButton.addTarget(self, action: #selector(addToFavourites(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func playAudio() {
        guard let audio = wordsToDisplay.soundURL, let audioURL = URL(string: audio) else {
            return
        }
        let playerItem = AVPlayerItem(url: audioURL)
        self.player = AVPlayer(playerItem: playerItem)
        player?.volume = 1.0
        player?.play()
        
        print("playing \(audioURL)")
    }
    
    @objc func addToFavourites(sender: UIButton) {
        if likes[sender.tag] == "star" {
            likes[sender.tag] = "star.fill"
        }
        else {
            likes[sender.tag] = "star"
        }
        sender.setBackgroundImage(UIImage(systemName: likes[sender.tag]), for: .normal)
    }
}


