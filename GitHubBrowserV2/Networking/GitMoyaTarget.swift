//
//  GitMoyaTarget.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/18/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import Foundation
import Moya

public enum Git {
    
    static private let gitOAuth = "token cbe072a1b995ab28b49ddb45fe0c5271b24908a6"
    
    case browse(Int)
    case search(String,Int)
    case loadMore(String)
}

extension Git: TargetType {
    public var baseURL: URL {
        switch self {
        case .search(_, _) : return URL(string: "https://api.github.com/search/repositories")!
        case .browse(_): return URL(string: "https://api.github.com/repositories")!
        case .loadMore(_): return URL(string: "https://api.github.com/repos/")!
        }
    }
    
    public var path: String {
        switch self {
        case .browse(_), .search(_, _): return ""
        case .loadMore(let name):
            return name
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .browse(let repoID):
            return .requestParameters(parameters: ["since" : repoID , "per_page" : 100], encoding: URLEncoding.default)
        case .search(let searchWord, let page):
            return .requestParameters(parameters: ["q" : searchWord , "page" : page, "per_page" : 100], encoding: URLEncoding.default)
        case .loadMore(_): return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .browse(_), .loadMore(_):
            return ["Authorization":Git.gitOAuth]
        case .search(_, _):
            return ["Authorization":Git.gitOAuth,
                    "Accept":"pplication/vnd.github.v3.text-match+json"]
        }
    }
    
    public var validationType: ValidationType {
        return .successCodes
    }
    
    
}
