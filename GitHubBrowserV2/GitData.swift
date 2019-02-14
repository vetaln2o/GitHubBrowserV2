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
    var url: String = ""
    var fullName: String = ""
    var fullNameRepo: String = ""
    var description: String?
    var updatedAt: String?
    var language: String?
    var stargazersCount: Int?
    var forksCount: Int?
    var owner: Owner = Owner()
    var textMatches: [TextMatches]?
    
    struct TextMatches {
        var property: String?
        var matches: [Matches]?
        
        init(){
        }
        
        init(json: [String : Any]) {
            self.property = json["property"] as? String
            if let matchArray = json["matches"] as? Array<Dictionary<String,Any>> {
                var newMatchesArray = [Matches]()
                for item in matchArray {
                    let newItem = Matches(json: item)
                    newMatchesArray.append(newItem)
                }
                self.matches = newMatchesArray
            }
        }
        
        struct Matches {
            var text: String?
            var indices: [Int]?
            init() {
            }
            init(json: [String : Any]) {
                self.text = json["text"] as? String
                self.indices = json["indices"] as? [Int]
            }
        }
    }
    
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
        self.id = (json["id"] as? Int) ?? 0
        self.htmlUrl = (json["html_url"] as? String) ?? ""
        self.url = (json["url"] as? String) ?? ""
        self.fullName = (json["name"] as? String) ?? ""
        self.fullNameRepo = (json["full_name"] as? String) ?? ""
        self.description = json["description"] as? String
        self.updatedAt = json["updated_at"] as? String
        self.language = json["language"] as? String
        self.stargazersCount = json["stargazers_count"] as? Int
        self.forksCount = json["forks_count"] as? Int
        if let owner = json["owner"] as? Dictionary<String,Any> {
            self.owner = Owner(json: owner)
        } else {
            self.owner = Owner()
        }
        if let matchesArray = json["text_matches"] as? Array<Dictionary<String,Any>> {
            var textMatchesArray = [TextMatches]()
            for match in matchesArray {
                let newMatch = TextMatches(json: match)
                textMatchesArray.append(newMatch)
            }
            self.textMatches = textMatchesArray
            print(textMatchesArray)
        }
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
        case loadMore
    }
    
    func getRepoList(from url: String, with type: TypeOfAction, completion: @escaping ([GitData]) -> Void) {
        var headers = HTTPHeaders()
        headers["Authorization"] = "token cbe072a1b995ab28b49ddb45fe0c5271b24908a6"
        if type == .search {
            headers["Accept"] = "pplication/vnd.github.v3.text-match+json"
        }
        request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseJSON) in
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
                case .loadMore:
                    guard let jsonObject = value as? [String : Any] else { return }
                    let git = GitData(json: jsonObject)
                    completion([git])
                }

            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadMoreInfo(for gitArray: [GitData], completion: @escaping ([GitData])->Void) {
        var fullGitArray = [GitData]()
        for (index, git) in gitArray.enumerated() {
            if git.updatedAt == nil {
                git.getRepoList(from: git.url, with: .loadMore) { (newGit) in
                    fullGitArray.append(newGit[0])
                    if index == gitArray.count - 1 {
                        completion(fullGitArray)
                    }
                }
            }
        }
    }
    
}
