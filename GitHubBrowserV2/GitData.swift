//
//  GitData.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/2/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import Foundation
import Alamofire

struct GitData {
    var id: Int = 0
    var htmlUrl: String = ""
    var fullName: String = ""
    var description: String?
    var updatedAt: String?
    var language: String?
    var stargazersCount: Int?
    var forksCount: Int?
    var owner: Owner = Owner()
    
    struct  Owner {
        var avatarUrl: String = ""
        var avatarImg: Data?
        
        init() {
            
        }
        
        init(json: [String : Any]) {
            self.avatarUrl = json["avatar_url"] as! String
        }
        init(avatarUrl: String) {
            self.avatarUrl = avatarUrl
        }
    }

    init() {
        
    }
    
    init (json: [String : Any]) {
        self.id = json["id"] as! Int
        self.htmlUrl = json["html_url"] as! String
        self.fullName = json["full_name"] as! String
        self.description = json["description"] as? String
        self.updatedAt = json["updated_at"] as? String
        self.language = json["language"] as? String
        self.stargazersCount = json["stargazers_count"] as? Int
        self.forksCount = json["forks_count"] as? Int
        self.owner = Owner(json: json["owner"] as! Dictionary<String,Any>)
    }
    
    init (id: Int, htmlUrl: String, fullName: String, description: String?,
          updatedAt: String?, language: String?, stargazersCount: Int?,
          forksCount: Int?, avatarUrl: String) {
        self.id = id
        self.htmlUrl = htmlUrl
        self.fullName = fullName
        self.description = description
        self.updatedAt = updatedAt
        self.language = language
        self.stargazersCount = stargazersCount
        self.forksCount = forksCount
        self.owner = Owner(avatarUrl: avatarUrl)
    }
    
    enum TypeOfAction {
        case search
        case browse
    }
    
    func getRepoList(from url: String, with type: TypeOfAction, completion: @escaping ([GitData]) -> Void) {
        request(url).responseJSON { (responseJSON) in
            switch responseJSON.result {
            case .success(let value):
                var gitDataArray: [GitData] = []
                switch type {
                case .browse:
                    guard let jsonArray = value as? Array<[String : Any]> else { return }
                    for jsonObject in jsonArray {
                        let git = GitData(json: jsonObject)
                        gitDataArray.append(git)
                    }
                    completion(gitDataArray)
                case .search:
                    guard let jsonAnswer = value as? [String : Any] else { return }
                    guard let jsonArray = jsonAnswer["items"] as? Array<[String : Any]> else { return }
                    for jsonObject in jsonArray {
                        let git = GitData(json: jsonObject)
                        gitDataArray.append(git)
                    }
                    completion(gitDataArray)
                }

            case .failure(let error):
                print(error)
            }
        }
    }
    
}
