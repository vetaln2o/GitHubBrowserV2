//
//  DetailViewController.swift
//  GitHubBrowserV2
//
//  Created by IOS Developer on 2/11/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import UIKit
import SafariServices
import Down
import Alamofire

class DetailViewController: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    
    var notExistAlert = UIAlertController()
    var notExistAlertAction = UIAlertAction()
    var loadIndicator = UIActivityIndicatorView(style: .gray)
    
    var gitRepository: GitData?
    
    var readmeUrlVariantArray: [String] {
        var newReadmeArray = [String]()
        if let currentRepository = gitRepository {
            var basicReadmeUrl = "https://raw.githubusercontent.com/\(currentRepository.fullName)/master/README"
            newReadmeArray.append(basicReadmeUrl)
            newReadmeArray.append(basicReadmeUrl + ".md")
            newReadmeArray.append(basicReadmeUrl + ".markdown")
            newReadmeArray.append(basicReadmeUrl + ".html")
            newReadmeArray.append(basicReadmeUrl + ".txt")
            newReadmeArray.append(basicReadmeUrl + ".rst")
            newReadmeArray.append(basicReadmeUrl + ".rdoc")
            basicReadmeUrl = "https://raw.githubusercontent.com/\(currentRepository.fullName)/master/readme"
            newReadmeArray.append(basicReadmeUrl)
            newReadmeArray.append(basicReadmeUrl + ".md")
            newReadmeArray.append(basicReadmeUrl + ".markdown")
            newReadmeArray.append(basicReadmeUrl + ".html")
            newReadmeArray.append(basicReadmeUrl + ".txt")
            newReadmeArray.append(basicReadmeUrl + ".rst")
            newReadmeArray.append(basicReadmeUrl + ".rdoc")
        }
        return newReadmeArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleTextField.text = gitRepository?.fullName ?? ""
        loadIndicator.center = view.center
        view.addSubview(loadIndicator)
        detailTextView.isHidden = true
        loadIndicator.hidesWhenStopped = true
        loadIndicator.startAnimating()
        favoritesButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getStringFromMD { (readme) in
            DispatchQueue.main.async {
                let down = Down(markdownString: readme)
                guard let attributedStringReadme = try? down.toAttributedString() else { return }
                self.detailTextView.attributedText = attributedStringReadme
                self.loadIndicator.stopAnimating()
                self.detailTextView.isHidden = false
            }
        }
        
        updateButtonForFavoritesProcessing()
        favoritesButton.isHidden = false
    }

    @IBAction func openInSafari(_ sender: Any? = nil) {
        guard let url = URL(string: gitRepository?.htmlUrl ?? "") else { return }
        let svc = SFSafariViewController(url: url)
        svc.delegate = self
        present(svc, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any? = nil) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func processFavorites(_ sender: UIButton) {
        if let repo = gitRepository {
            if sender.tag == 1 {
                FavoritesDB.shared.saveToFavorites(from: repo)
                print("Repo Saved to favorites")
                updateButtonForFavoritesProcessing()
            } else if sender.tag == 2 {
                FavoritesDB.shared.deleteFromFavoritesWith(repo.id)
                print("Repo deleted form favorites")
                updateButtonForFavoritesProcessing()
            }
        }
    }
    
    private func updateButtonForFavoritesProcessing() {
        if let repo = gitRepository {
            if FavoritesDB.shared.checkExistRepository(with: repo.id) {
                favoritesButton.setTitle("Delete from favorites", for: .normal)
                favoritesButton.setTitleColor(.red, for: .normal)
                favoritesButton.tag = 2
                print("Label changed to delet from")
            } else {
                favoritesButton.setTitle("Add to favorites", for: .normal)
                favoritesButton.setTitleColor(.green, for: .normal)
                favoritesButton.tag = 1
                print("Label changed to add to")
            }
        }
    }
    
    private func getStringFromMD(_ completion: @escaping (String) -> Void) {
        var isReadmeExist = [Bool]()
        for url in readmeUrlVariantArray {
            if let urlFromString = URL(string: url) {
                request(urlFromString).responseString { (readmeContext) in
                    switch readmeContext.result {
                    case .success(let readme):
                        if readmeContext.response?.statusCode != 404 {
                            isReadmeExist.append(true)
                            completion(readme)
                        } else {
                            isReadmeExist.append(false)
                        }
                        if isReadmeExist.count == self.readmeUrlVariantArray.count {
                            if !isReadmeExist.contains(true) {
                                self.showNotExtistAlert()
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }

    }
    
    private func showNotExtistAlert() {
        self.notExistAlert = UIAlertController(title: "README", message: "Readme file not exist in \((self.gitRepository?.fullName)!). Open Repository in Safari?", preferredStyle: .alert)
        self.notExistAlertAction = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            self.openInSafari()
        })
        self.notExistAlert.addAction(self.notExistAlertAction)
        self.notExistAlertAction = UIAlertAction(title: "No", style: .default, handler: { (alert) in
            self.dismiss(animated: true, completion: nil)
        })
        self.notExistAlert.addAction(self.notExistAlertAction)
        self.present(self.notExistAlert, animated: true)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        goBack()
    }
    
}
