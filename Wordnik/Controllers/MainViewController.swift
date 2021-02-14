//
//  MainViewController.swift
//  Wordnik
//
//  Created by User on 2/13/21.
//  Copyright © 2021 Syrym Zhursin. All rights reserved.
//

import UIKit
import Moya

class MainViewController: UIViewController {
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Type any word"
        searchBar.autocapitalizationType = .none
        searchBar.showsCancelButton = false
        return searchBar
    }()
    

    var cardView = CardView()
    
    let provider = MoyaProvider<APIService>()
    
    var wordsToDisplay: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupViews()
    }
    
    private func setupViews() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Words"
        searchBar.delegate = self
        let elementsUI = [searchBar, cardView]
        elementsUI.forEach { (element) in
            self.view.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            cardView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 50),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            cardView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }
    
    // MARK: - NETWORKING
    
    private func getSynonyms(_ text: String) {
        provider.request(.getSynonyms(text: text)) { [weak self] (result) in
            switch result {
            case .success(let response):
                do {
//                    if let json = try JSONSerialization.jsonObject(with: response.data, options: []) as? [[String : Any]] {
//                        print("json: \(json)")
//                    }
                    let wordnikResponse = try JSONDecoder().decode([WordnikResponse].self, from: response.data)
//                    guard let synonyms = wordnikResponse.first, let firstSynonym = synonyms.words.first else {
//                        return
//                    }
//                    self?.cardView.setText(firstSynonym)
//                    print("wordnikResponse: \(wordnikResponse.first?.words)")
                    guard let synonyms = wordnikResponse.first?.words else {
                        return
                    }
                    self?.wordsToDisplay = synonyms
                    self?.cardView.setText(self?.wordsToDisplay[0] ?? "")
                    print(self?.wordsToDisplay ?? "")
                } catch let error{
                    print("Parsing error: \(error)")
                }
            case .failure(let error):
                let requestError = error as NSError
                print("Request error: \(requestError.localizedDescription), code: \(requestError.code)")
            }
        }
    }

}
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        self.getSynonyms(searchText)
        searchBar.endEditing(true)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        print("\(#function)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wordsToDisplay.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SynonymCollectionViewCell", for: indexPath) as! SynonymCollectionViewCell
        cell.layer.borderWidth = 2
        print(wordsToDisplay)
        return cell
    }
    
    
}
