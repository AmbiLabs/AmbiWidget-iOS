//
//  LoadingViewController.swift
//  TodayExtension
//
//  Created by Milan Sosef on 04/01/2019.
//  Copyright © 2019 tonglaicha. All rights reserved.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController {
    private lazy var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("LoadingViewController added")
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 0.5 second delay to not show an activity indicator
        // in case the data loads very quickly.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
}
