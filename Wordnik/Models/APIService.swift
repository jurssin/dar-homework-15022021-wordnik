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
}

extension APIService: TargetType {
    var baseURL: URL {
        return URL(string: "http://api.wordnik.com:80/v4/word.json")!
    }
    
    var path: String {
        switch self {
        case .getSynonyms(let text):
            return "\(text)/relatedWords"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getSynonyms:
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
                "limitPerRelationshipType" : "5",
                "api_key" : "a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type" : "application/json"]
    }
    
    
}
