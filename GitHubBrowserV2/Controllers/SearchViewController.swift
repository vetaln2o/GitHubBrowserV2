//
//  SearchViewController.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/2/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, NewFavoritesAddedDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var contentTableView: UITableView!
    
    var loadMoreIndicator = UIActivityIndicatorView(style: .white)
    var tableLoadIndicator = UIActivityIndicatorView(style: .gray)
    
    var footerView = UIView()
    var messageForAddingToFavorites = MessageLabel()
    
    var gitData = GitData()
    var gitDataArray = [GitData]()
    var repositoryListPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.register(RepositoryInfoTableViewCell.self, forCellReuseIdentifier: "ContentCell")
        
        messageForAddingToFavorites = MessageLabel(frame: CGRect(x: view.frame.minX+15, y: view.frame.maxY - 150, width: view.frame.width - 30, height: 30))
        view.addSubview(messageForAddingToFavorites)

        searchBar.becomeFirstResponder()
        tableLoadIndicator.center = view.center
        tableLoadIndicator.hidesWhenStopped = true
        view.addSubview(tableLoadIndicator)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let detailVC = segue.destination as? DetailViewController {
                detailVC.gitRepository = gitDataArray[contentTableView.indexPathForSelectedRow?.row ?? 0]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gitDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contentTableView.dequeueReusableCell(withIdentifier: "ContentCell") as! RepositoryInfoTableViewCell
        cell.pushInfoToCell(from: gitDataArray[indexPath.row], is: true)
        cell.processAddingToFavoritesDelegate = self
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            if searchText.count > 2 {
                repositoryListPage = 1
                tableLoadIndicator.startAnimating()
                contentTableView.isHidden = true
                gitData.getRepoList(
                    from: "https://api.github.com/search/repositories?q=\(searchText)&page=\(repositoryListPage)&per_page=100",
                with: .search) { (gitArray) in
                    DispatchQueue.main.async { [weak self] in
                        self?.gitDataArray = gitArray
                        self?.contentTableView.reloadData()
                        self?.tableLoadIndicator.stopAnimating()
                        self?.contentTableView.isHidden = false
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

    var loadingMoreProcess = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 && loadingMoreProcess == false {
            loadingMoreProcess = true
            footerView.isHidden = false
            scrollView.isScrollEnabled = false
            loadMoreIndicator.startAnimating()
            loadMoreRepositories()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: contentTableView.frame.width, height: 30))
        footerView.backgroundColor = .gray
        loadMoreIndicator.center = footerView.center
        footerView.isHidden = true
        footerView.addSubview(loadMoreIndicator)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: nil)
    }
    
    func loadMoreRepositories() {
        if let searchText = searchBar.text {
            repositoryListPage += 1
            gitData.getRepoList(from: "https://api.github.com/search/repositories?q=\(searchText)&page=\(repositoryListPage)&per_page=100", with: .search) { (newGitData) in
                DispatchQueue.main.async { [weak self] in
                    self?.gitDataArray += newGitData
                    self?.loadMoreIndicator.stopAnimating()
                    self?.footerView.isHidden = true
                    self?.contentTableView.isScrollEnabled = true
                    self?.contentTableView.reloadData()
                    self?.loadingMoreProcess = false
                }
            }
        }
    }
    
    func processAddingToFavorites(repository: GitData) {
        messageForAddingToFavorites.showWindow(with: "'\(repository.fullNameRepo)' was added to favorites!")
    }


}
