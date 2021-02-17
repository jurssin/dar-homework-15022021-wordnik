//
//  MainViewPresenter.swift
//  Wordnik
//
//  Created by User on 2/17/21.
//  Copyright © 2021 Syrym Zhursin. All rights reserved.
//

import Foundation
import Moya

protocol MainViewProtocol {
    func setSynonyms(text: [String])
    func setDefinition(text: String)
    func showError(text: String)
    func setSearchText(text: String)
    func showActivityIndicator()
    func hideActivityIndicator()
    func playAudio(url: String)
}

protocol MainViewPresenterProtocol {
    init(view: MainViewProtocol)
    func getInputText(text: String)
}

class MainPresenter: MainViewPresenterProtocol {
    
    let view: MainViewProtocol
    let provider = MoyaProvider<APIService>()
    var wordsToDisplay = WordsToDisplay()
    var likes: [String] = []


    required init(view: MainViewProtocol) {
        self.view = view
    }
    
    func getInputText(text: String) {
        getSynonyms(text)
        getDefinition(text)
        getAudio(text)
    }
    
    private func getSynonyms(_ text: String) {
        self.view.showActivityIndicator()
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
                    print(self?.wordsToDisplay.synonyms ?? "")
                    self?.view.setSynonyms(text: self?.wordsToDisplay.synonyms ?? [])
                    self?.view.setSearchText(text: self?.wordsToDisplay.searchText ?? "")

                } catch let error {
                    self?.view.showError(text: error.localizedDescription)
                    self?.view.setSynonyms(text: [])
                    self?.view.setSearchText(text: "")
                    
                    print("Parsing error: \(error.localizedDescription)")
                }

            case .failure(let error):
                let requestError = error as NSError
                print("Request error: \(requestError.localizedDescription), code: \(requestError.code)")
                

            }
            self?.view.hideActivityIndicator()
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
                    self?.view.setDefinition(text: self?.wordsToDisplay.definitionText ?? "")
                    print("def: - ", definition)
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
                    self?.view.playAudio(url: self?.wordsToDisplay.soundURL ?? "")
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
