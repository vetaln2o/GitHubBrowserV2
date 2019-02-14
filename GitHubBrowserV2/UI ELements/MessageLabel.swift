//
//  messageLabel.swift
//  GitHubBrowserV2
//
//  Created by IOS Developer on 2/14/19.
//  Copyright © 2019 Vitalij Semenenko. All rights reserved.
//

import UIKit

class MessageLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.textAlignment = .center
        self.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        self.layer.cornerRadius = 8
        self.isHidden = true
        self.alpha = 1.0
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showWindow(with message: String) {
        self.isHidden = false
        self.alpha = 1.0
        self.text = message
        let showMessageAnimation = UIViewPropertyAnimator(duration: 3, curve: .easeInOut) {
            self.alpha = 0.0
        }
        showMessageAnimation.startAnimation(afterDelay: 2)
    }

}
