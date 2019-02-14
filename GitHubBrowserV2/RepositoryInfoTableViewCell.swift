//
//  RepositoryInfoTableViewCell.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/2/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import UIKit
import Alamofire

class RepositoryInfoTableViewCell: UITableViewCell {
    
    var addToFavoritesButton = UIButton(type: UIButton.ButtonType.contactAdd)
    var repositoryNameLable = UILabel()
    var repositoryDescriptionTextView = UITextView()
    var avatarImageView = UIImageView()
    var starsLabel = UILabel()
    var languageLabel = UILabel()
    var updateDataLabel = UILabel()
    var forksLabel = UILabel()
    
    var cellRepoInfo = GitData(id: 0, htmlUrl: "", fullName: "", description: nil, updatedAt: nil, language: nil, stargazersCount: nil, forksCount: nil, avatarUrl: "")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(addToFavoritesButton)
        self.addSubview(repositoryNameLable)
        self.addSubview(repositoryDescriptionTextView)
        self.addSubview(avatarImageView)
        self.addSubview(starsLabel)
        self.addSubview(languageLabel)
        self.addSubview(updateDataLabel)
        self.addSubview(forksLabel)
        
        repositoryDescriptionTextView.isEditable = false
        
        addToFavoritesButton.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        
        self.subviews.forEach { (subview) in
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.isUserInteractionEnabled = false
        }
        
        addToFavoritesButton.isUserInteractionEnabled = true
        
        addCounstraints()
        
        repositoryNameLable.textColor = .blue
        
        repositoryDescriptionTextView.sizeToFit()
        repositoryDescriptionTextView.isEditable = false
        repositoryDescriptionTextView.isScrollEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageLoadingInProgress = 0
    
    func pushInfoToCell(from repository: GitData, is forSearch: Bool? = nil) {
        cellRepoInfo = repository
        if forSearch == nil {
            self.repositoryNameLable.text = repository.fullName
            self.repositoryDescriptionTextView.text = repository.description
        } else {
            self.repositoryNameLable.attributedText = highlight(search: repository.fullName, for: "name")
            if let description = repository.description {
                self.repositoryDescriptionTextView.attributedText = highlight(search: description, for: "description")
            }
        }
        self.languageLabel.text = repository.language
        if var date = repository.updatedAt {
            self.updateDataLabel.text = getUpdateDate(stringData: &date)
        }
        if let stars = repository.stargazersCount {
            self.starsLabel.text = "★ \(stars)"
        }
        if let forks = repository.forksCount {
            self.forksLabel.text = "\(forks) forks"
        }
        self.avatarImageView.image = UIImage()
        imageLoadingInProgress += 1
        takeImage(from: repository.owner.avatarUrl) { (image) in
            if self.imageLoadingInProgress == 1 {
                DispatchQueue.main.async {
                    self.avatarImageView.image = image
                    self.imageLoadingInProgress -= 1
                }
            } else {
                self.imageLoadingInProgress -= 1
            }
        }
    }
    
    private func highlight(search text: String, for property: String?) -> NSMutableAttributedString {
        let highlightedString = NSMutableAttributedString(string: text)
        if let textMatches = cellRepoInfo.textMatches {
            for attribute in textMatches {
                if attribute.property == property {
                    for rangeInt in attribute.matches! {
                        if let indices = rangeInt.indices {
                            let range: NSRange = NSMakeRange(indices[0], indices[1] - indices[0])
                            highlightedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
                        }
                    }
                }
            }
        }
        return highlightedString
    }
    
    @objc private func addToFavorites() {
        print("Repo added \(cellRepoInfo.id)")
        let currentFavoritesArray = FavoritesDB.shared.getFavoritesRepositories()
        if !currentFavoritesArray.contains(where: { (gitInfo) -> Bool in
            return gitInfo.id == cellRepoInfo.id
        }) {
            FavoritesDB.shared.saveToFavorites(from: cellRepoInfo)
        }
    }
    
    private func addCounstraints() {
        repositoryNameLable.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        repositoryNameLable.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        repositoryNameLable.heightAnchor.constraint(equalToConstant: 20).isActive = true
        repositoryNameLable.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -100).isActive = true
        
        updateDataLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        updateDataLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        updateDataLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        
        languageLabel.bottomAnchor.constraint(equalTo: updateDataLabel.topAnchor, constant: -5).isActive = true
        languageLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        languageLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        forksLabel.bottomAnchor.constraint(equalTo: updateDataLabel.topAnchor, constant: -5).isActive = true
        forksLabel.leftAnchor.constraint(equalTo: languageLabel.rightAnchor, constant: 10).isActive = true
        forksLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        repositoryDescriptionTextView.topAnchor.constraint(equalTo: repositoryNameLable.bottomAnchor, constant: 5).isActive = true
        repositoryDescriptionTextView.bottomAnchor.constraint(equalTo: languageLabel.topAnchor, constant: -5).isActive = true
        repositoryDescriptionTextView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        repositoryDescriptionTextView.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -100).isActive = true
        
        addToFavoritesButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        addToFavoritesButton.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        addToFavoritesButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        addToFavoritesButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        avatarImageView.rightAnchor.constraint(equalTo: addToFavoritesButton.leftAnchor, constant: -5).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        starsLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 5).isActive = true
        starsLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        starsLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        starsLabel.leftAnchor.constraint(equalTo: avatarImageView.leftAnchor).isActive = true
        
    }
    
    private func getUpdateDate(stringData: inout String) -> String {
        var resultUpdatesAgo = "Updated "
        
        stringData.removeLast()
        var temp = stringData.split(separator: "T")
        stringData = temp[0]+" "+temp[1]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dataFromString = formatter.date(from: stringData)!
        
        var difference : (years:Int, days:Int, hours:Int)
        
        difference.years = Calendar.current.dateComponents([.year], from: dataFromString, to: Date()).year!
        difference.days = Calendar.current.dateComponents([.day], from: dataFromString, to: Date()).day!
        difference.hours = Calendar.current.dateComponents([.hour], from: dataFromString, to: Date()).hour!
        
        switch difference {
        case (let year,_,_) where year == 1: resultUpdatesAgo += "a year ago"
        case (let year,_,_) where year > 1: resultUpdatesAgo += "\(year) years ago"
        case (_,let day,_) where day == 1: resultUpdatesAgo += "a day ago"
        case (_,let day,_) where day > 1: resultUpdatesAgo += "\(day) days ago"
        case (_,_,let hour) where hour == 1: resultUpdatesAgo += "an hour ago"
        case (_,_,let hour) where hour > 1: resultUpdatesAgo += "\(hour) hours ago"
        default:
            resultUpdatesAgo = ""
        }
        return resultUpdatesAgo
    }
    
    private func takeImage(from url: String, completion: @escaping (UIImage) -> Void) {
        request(url).responseData { (responseData) in
            switch responseData.result {
            case .success(let data):
                guard let image = UIImage(data: data) else {return}
                completion(image)
            case .failure(let error): print(error)
            }
        }
    }
}
