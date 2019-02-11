//
//  ViewController.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/2/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import UIKit
import RealmSwift

class BrowseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contentTableView: UITableView!
    var loadMoreIndicator = UIActivityIndicatorView(style: .white)
    var tableLoadIndicator = UIActivityIndicatorView(style: .gray)
    var footerView = UIView()
    
    var gitData = GitData()
    var gitDataArray = [GitData]()

    override func viewDidLoad() {
        super.viewDidLoad()

        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.register(RepositoryInfoTableViewCell.self, forCellReuseIdentifier: "ContentCell")
        contentTableView.tableFooterView?.isHidden = true
        contentTableView.rowHeight = UITableView.automaticDimension
        contentTableView.estimatedRowHeight = 44
        
        tableLoadIndicator.center = view.center
        view.addSubview(tableLoadIndicator)
        tableLoadIndicator.hidesWhenStopped = true
        tableLoadIndicator.startAnimating()
        contentTableView.isHidden = true
        gitData.getRepoList(from: "https://api.github.com/repositories?since=1&per_page=100", with: .browse) { (data) in
            DispatchQueue.main.async { [weak self] in
                self?.gitDataArray = data
                self?.contentTableView.reloadData()
                self?.tableLoadIndicator.stopAnimating()
                self?.contentTableView.isHidden = false
            }
        }
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
        if !gitDataArray.isEmpty {
            cell.pushInfoToCell(from: gitDataArray[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: contentTableView.frame.width, height: 30))
        footerView.backgroundColor = .gray
        loadMoreIndicator.center = footerView.center
        footerView.isHidden = true
        footerView.addSubview(loadMoreIndicator)
        return footerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 {
            footerView.isHidden = false
            scrollView.isScrollEnabled = false
            loadMoreIndicator.startAnimating()
            loadMoreRepositories()
        }
    }
    
    private func loadMoreRepositories() {
        if let lastRepositoryID = gitDataArray.last?.id {
            gitData.getRepoList(from: "https://api.github.com/repositories?since=\(lastRepositoryID)&per_page=100", with: .browse) { (data) in
                DispatchQueue.main.async { [weak self] in
                    self?.gitDataArray += data
                    self?.contentTableView.reloadData()
                    self?.contentTableView.isScrollEnabled = true
                    self?.loadMoreIndicator.stopAnimating()
                    self?.footerView.isHidden = true
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: nil)
    }

}

