//
//  CardView.swift
//  Wordnik
//
//  Created by User on 2/13/21.
//  Copyright © 2021 Syrym Zhursin. All rights reserved.
//

import UIKit

final class CardView: UIView {

    lazy var textLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setStyles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func setText(_ text: String) {
        self.textLabel.text = text
    }
    
    private func setupViews() {
    
        let elementsUI = [textLabel]
        elementsUI.forEach { (element) in
            self.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    private func setStyles() {
        
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.backgroundColor = .white
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.init(width: 5, height: 5)
        self.layer.masksToBounds = false
        

    }
    
}
