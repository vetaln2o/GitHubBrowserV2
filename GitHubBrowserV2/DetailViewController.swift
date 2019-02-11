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

class DetailViewController: UIViewController {
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
            newReadmeArray.append(basicReadmeUrl + ".txt")
            newReadmeArray.append(basicReadmeUrl + ".rst")
            newReadmeArray.append(basicReadmeUrl + ".rdoc")
            basicReadmeUrl = "https://raw.githubusercontent.com/\(currentRepository.fullName)/master/readme"
            newReadmeArray.append(basicReadmeUrl)
            newReadmeArray.append(basicReadmeUrl + ".md")
            newReadmeArray.append(basicReadmeUrl + ".markdown")
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
        
        getStringFromMD { (readme) in
            DispatchQueue.main.async {
                let down = Down(markdownString: readme)
                guard let attributedStringReadme = try? down.toAttributedString() else { return }
                self.detailTextView.attributedText = attributedStringReadme
                self.loadIndicator.stopAnimating()
                self.detailTextView.isHidden = false
            }
        }
    }

    @IBAction func openInSafari(_ sender: Any? = nil) {
        guard let url = URL(string: gitRepository?.htmlUrl ?? "") else { return }
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getStringFromMD(_ completion: @escaping (String) -> Void) {
        var isReadmeExist = [Bool]()
        for url in readmeUrlVariantArray {
            if let urlFromString = URL(string: url) {
                request(urlFromString).responseString { (readmeContext) in
                    switch readmeContext.result {
                    case .success(let readme):
                        if readmeContext.response?.statusCode != 404 {
                            completion(readme)
                            isReadmeExist.append(true)
                        } else {
                            isReadmeExist.append(false)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
        if !isReadmeExist.contains(true) {
            showNotExtistAlert()
        }
    }
    
    private func showNotExtistAlert() {
        self.notExistAlert = UIAlertController(title: "README", message: "Readme file not exist in \((self.gitRepository?.fullName)!). Open Repository in Safari?", preferredStyle: .alert)
        self.notExistAlertAction = UIAlertAction(title: "Yes", style: .default, handler: { (alert) in
            self.openInSafari()
            self.dismiss(animated: true, completion: nil)
        })
        self.notExistAlert.addAction(self.notExistAlertAction)
        self.notExistAlertAction = UIAlertAction(title: "No", style: .default, handler: { (alert) in
            self.dismiss(animated: true, completion: nil)
        })
        self.notExistAlert.addAction(self.notExistAlertAction)
        self.present(self.notExistAlert, animated: true)
    }
    
}
