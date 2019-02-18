//
//  GitData.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/2/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import Foundation
import Alamofire
import Moya

struct GitData: Codable {
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
    var owner: Owner
    var textMatches: [TextMatches]?
    
    private enum CodingKeys: String, CodingKey
    {
        case id
        case htmlUrl = "html_url"
        case url
        case fullName = "name"
        case fullNameRepo = "full_name"
        case description
        case updatedAt = "updated_at"
        case language
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case owner
        case textMatches = "text_matches"
    }
    
    
    struct TextMatches: Codable {
        var property: String?
        var matches: [Matches]?
        
        private enum CodingKeys: String, CodingKey {
            case property
            case matches
        }
        
        init(){
        }
        
        struct Matches: Codable {
            var text: String?
            var indices: [Int]?
            init() {
            }
        }
    }
    
    struct  Owner: Codable {
        var avatarUrl: String = ""
        var avatarImg: Data?
        
        private enum CodingKeys: String, CodingKey {
            case avatarUrl = "avatar_url"
            case avatarImg
        }
        init() {
            
        }

        init(avatarUrl: String) {
            self.avatarUrl = avatarUrl
        }
    }

    init() {
        self.owner = Owner()
    }
 
    init (id: Int, htmlUrl: String, url: String, fullName: String, fullNameRepo: String, description: String?,
          updatedAt: String?, language: String?, stargazersCount: Int?,
          forksCount: Int?, avatarUrl: String) {
        self.id = id
        self.htmlUrl = htmlUrl
        self.url = url
        self.fullName = fullName
        self.fullNameRepo = fullNameRepo
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
    
    func getRepoList(actionType: TypeOfAction, page: Int?=nil, searchWord: String?=nil, repoName: String?=nil, completion: @escaping ([GitData]) -> Void)  {
        let provider = MoyaProvider<Git>(plugins: [NetworkLoggerPlugin(verbose: true)])
        switch actionType {
        case .browse:
            provider.request(.browse(page ?? 1)) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let result = try JSONDecoder().decode([GitData].self, from: response.data)
                        completion(result)
                    } catch (let error) {
                        print("Error parsing json: \(error)")
                    }
                case .failure(let error): print(error)
                }
            }
        case .search:
            provider.request(.search(searchWord ?? "", page ?? 1)) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let result = try response.map([GitData].self, atKeyPath: "items", using: JSONDecoder(), failsOnEmptyData: false)
                        completion(result)
                    } catch (let error) {
                        print("Error parsing json: \(error)")
                    }
                case .failure(let error): print(error)
                }
            }
        case .loadMore:
            provider.request(.loadMore(repoName ?? "")) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let result = try response.map(GitData.self)
                        completion([result])
                    } catch  (let error) {
                        print("Error parsing json: \(error)")
                    }
                case .failure(let error): print(error)
                }
            }
            
        }
    }

    func loadMoreInfo(for gitArray: [GitData], completion: @escaping ([GitData])->Void) {
        let loadGroup = DispatchGroup()
        var fullGitArray = [GitData]()
        let _ = DispatchQueue.global(qos: .userInitiated)
        DispatchQueue.concurrentPerform(iterations: gitArray.count) { index in
            if gitArray[index].updatedAt == nil {
                loadGroup.enter()
                gitArray[index].getRepoList(actionType: .loadMore, page: nil, searchWord: nil, repoName: gitArray[index].fullNameRepo, completion: { (newGit) in
                    fullGitArray.append(newGit[0])
                    loadGroup.leave()
                })
            }
        }
        loadGroup.notify(queue: DispatchQueue.main) {
            completion(fullGitArray)
        }
    }
}

protocol NewFavoritesAddedDelegate {
    func processAddingToFavorites(repository: GitData)
}
