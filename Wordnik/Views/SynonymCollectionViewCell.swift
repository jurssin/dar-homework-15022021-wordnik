//
//  SynonymCollectionViewCell.swift
//  Wordnik
//
//  Created by User on 2/14/21.
//  Copyright © 2021 Syrym Zhursin. All rights reserved.
//

import UIKit

class SynonymCollectionViewCell: UICollectionViewCell {
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    lazy var searchWord: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.backgroundColor = .systemGray6
        return label
    }()
    
    lazy var definitionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont.italicSystemFont(ofSize: 15)
        label.numberOfLines = 5
        //label.backgroundColor = .blue
        return label
    }()
    
    lazy var playWordButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.tintColor = .black
        return button
    }()
    
    lazy var synonymsWordLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.backgroundColor = .systemGray5
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupStyle()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupStyle() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5
    }
    private func setupView() {
        let elementsUI = [searchWord, synonymsWordLabel, playWordButton, definitionLabel]
        elementsUI.forEach { (element) in
            self.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            
            searchWord.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            searchWord.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            playWordButton.centerYAnchor.constraint(equalTo: searchWord.centerYAnchor),
            playWordButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            playWordButton.heightAnchor.constraint(equalToConstant: 30),
            playWordButton.widthAnchor.constraint(equalToConstant: 25),
            
            definitionLabel.topAnchor.constraint(equalTo: searchWord.bottomAnchor, constant: 5),
            definitionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            definitionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),

            synonymsWordLabel.topAnchor.constraint(equalTo: definitionLabel.bottomAnchor, constant: 10),
            synonymsWordLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
            
        ])
        
    }
}
