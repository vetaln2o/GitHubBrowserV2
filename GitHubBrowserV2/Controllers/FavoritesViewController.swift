//
//  FavoritesViewController.swift
//  GitHubBrowserV2
//
//  Created by Vitalij Semenenko on 2/2/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var contentTable: UITableView!
    
    var favoritesArray = [GitData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTable.delegate = self
        contentTable.dataSource = self
        contentTable.register(RepositoryInfoTableViewCell.self, forCellReuseIdentifier: "ContentCell")

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        favoritesArray = FavoritesDB.shared.getFavoritesRepositories()
        contentTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let detailVC = segue.destination as? DetailViewController {
                detailVC.gitRepository = favoritesArray[contentTable.indexPathForSelectedRow?.row ?? 0]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = contentTable.dequeueReusableCell(withIdentifier: "ContentCell") as! RepositoryInfoTableViewCell
        cell.pushInfoToCell(from: favoritesArray[indexPath.row])
        cell.addToFavoritesButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FavoritesDB.shared.deleteFromFavorites(indexPath.row)
            favoritesArray.remove(at: indexPath.row)
            contentTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowDetail", sender: nil)
    }
    
    @IBAction func clearFavorites(_ sender: Any) {
        let alert = UIAlertController(title: "Warning!", message: "Are you sure to clean favorites?", preferredStyle: .alert)
        let alertActionClean = UIAlertAction(title: "Clean", style: .destructive) { (action) in
            FavoritesDB.shared.deleteAllRealm()
            self.favoritesArray.removeAll()
            self.contentTable.reloadData()
        }
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(alertActionClean)
        alert.addAction(alertActionCancel)
        self.present(alert, animated: true)
    }
    
}
