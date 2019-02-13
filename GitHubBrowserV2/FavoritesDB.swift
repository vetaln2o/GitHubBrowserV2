//
//  FavoritesDB.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/7/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import Foundation
import RealmSwift

class Repository: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var htmlUrl: String = ""
    @objc dynamic var fullName: String = ""
    @objc dynamic var repDescription: String?
    @objc dynamic var updatedAt: String?
    @objc dynamic var language: String?
    var stargazersCount = RealmOptional<Int>()
    var forksCount = RealmOptional<Int>()
    @objc dynamic var owner: Owner?
}

class Owner: Object {
    @objc dynamic var avatarUrl: String = ""
}

class FavoritesDB {
    public static var shared = FavoritesDB()
    
    private let uiRealm = try! Realm()
    
    func getFavoritesRepositories() -> [GitData] {
        var favoritesArray = [GitData]()
        let favoritesFromDB = uiRealm.objects(Repository.self)
        for element in favoritesFromDB {
            favoritesArray.append(GitData(id: element.id, htmlUrl: element.htmlUrl,
                                          fullName: element.fullName, description: element.repDescription,
                                          updatedAt: element.updatedAt, language: element.language,
                                          stargazersCount: element.stargazersCount.value, forksCount: element.forksCount.value,
                                          avatarUrl: element.owner?.avatarUrl ?? ""))
        }
        return favoritesArray
    }
    
    func saveToFavorites(from repository: GitData) {
        let newRepo = getDBObject(from: repository)
        try! uiRealm.write {
            uiRealm.add(newRepo)
        }
    }
    
    private func getDBObject(from repository: GitData) -> Repository {
        let newRepo = Repository()
        newRepo.id = repository.id
        newRepo.htmlUrl = repository.htmlUrl
        newRepo.fullName = repository.fullName
        newRepo.repDescription = repository.description
        newRepo.updatedAt = repository.updatedAt
        newRepo.language = repository.language
        newRepo.stargazersCount.value = repository.stargazersCount
        newRepo.forksCount.value = repository.forksCount
        newRepo.owner = Owner()
        newRepo.owner?.avatarUrl = repository.owner.avatarUrl
        return newRepo
    }
    
    func deleteAllRealm() {
        try! uiRealm.write {
            uiRealm.deleteAll()
        }
    }
    
    func deleteFromFavorites(_ repositoryIndex: Int) {
        let favoritesFromDB = uiRealm.objects(Repository.self)
        let deletedRepo = favoritesFromDB[repositoryIndex]
        try! uiRealm.write {
            uiRealm.delete(deletedRepo)
        }
    }
    
    func deleteFromFavoritesWith(_ repositoryId: Int) {
        let favoritesFromDB = uiRealm.objects(Repository.self)
        var deletedRepo = [Repository]()
        for repo in favoritesFromDB {
            if repo.id == repositoryId {
                deletedRepo.append(repo)
                break
            }
        }
        try! uiRealm.write {
            uiRealm.delete(deletedRepo[0])
        }
    }
    
    func checkExistRepository(with repoID: Int) -> Bool {
        let favoritesFromDB = uiRealm.objects(Repository.self)
        for repo in favoritesFromDB {
            if repo.id == repoID {
                return true
            }
        }
        return false
    }
}
