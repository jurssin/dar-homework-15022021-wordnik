//
//  APIService.swift
//  Wordnik
//
//  Created by User on 2/13/21.
//  Copyright © 2021 Syrym Zhursin. All rights reserved.
//

import Foundation
import Moya

enum APIService {
    case getSynonyms(text: String)
    case getPronounciation(text: String)
    case getDefinition(text: String)
    case getAudio(text: String)
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "http://api.wordnik.com:80/v4/word.json")!
    }
    
    var path: String {
        switch self {
        case .getSynonyms(let text):
            return "\(text)/relatedWords"
        case .getPronounciation(let text):
            return "\(text)/pronunciations"
        case .getDefinition(let text):
            return "\(text)/definitions"
        case .getAudio(let text):
            return "\(text)/audio"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSynonyms, .getAudio, .getDefinition, .getPronounciation:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getSynonyms:
            let params: [String : String] = [
                "useCanonical" : "false",
                "relationshipTypes" : "synonym",
                "limitPerRelationshipType" : "20",
                "api_key" : "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .getPronounciation:
            let params: [String : String] = [
                "useCanonical" : "false",
                "limitPerRelationshipType" : "1",
                "api_key" : "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)

        case .getDefinition:
            let params: [String : String] = [
                "limit" : "1",
                "includeRelated" : "false",
                "sourceDictionaries" : "century",
                "useCanonical" : "false",
                "includeTags" : "false",
                "api_key" : "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .getAudio:
            let params: [String : String] = [
                "useCanonical" : "false",
                "limit" : "1",
                "api_key" : "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type" : "application/json"]
    }
}
