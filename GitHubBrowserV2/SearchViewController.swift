//
//  SearchViewController.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/2/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentTableView: UITableView!
    
    var loadMoreIndicator = UIActivityIndicatorView(style: .white)
    var tableLoadIndicator = UIActivityIndicatorView(style: .gray)
    
    var gitData = GitData()
    var gitDataArray = [GitData]()
    var repositoryListPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.register(RepositoryInfoTableViewCell.self, forCellReuseIdentifier: "ContentCell")

        searchBar.becomeFirstResponder()
        tableLoadIndicator.center = view.center
        tableLoadIndicator.hidesWhenStopped = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gitDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contentTableView.dequeueReusableCell(withIdentifier: "ContentCell") as! RepositoryInfoTableViewCell
        cell.pushInfoToCell(from: gitDataArray[indexPath.row])
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            if searchText.count > 2 {
                tableLoadIndicator.startAnimating()
                gitData.getRepoList(
                    from: "https://api.github.com/search/repositories?q=\(searchText)&page=\(repositoryListPage)&per_page=100",
                with: .search) { (gitArray) in
                    DispatchQueue.main.async { [weak self] in
                        self?.gitDataArray = gitArray
                        self?.contentTableView.reloadData()
                        self?.tableLoadIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        
    }

}
