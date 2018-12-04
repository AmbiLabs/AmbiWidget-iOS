//
//  ComfortMode.swift
//  TodayExtension
//
//  Created by Milan Sosef on 4/12/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit

class ComfortMode: UIViewController {

    @IBOutlet var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func touchComfortButton(_ sender: UIButton) {
        var comfortTag: String?
        
        switch sender.tag {
        case 1:
            comfortTag = "too_warm"
        case 2:
            comfortTag = "bit_warm"
        case 3:
            comfortTag = "comfy"
        case 4:
            comfortTag = "bit_cold"
        case 5:
            comfortTag = "too_cold"
        default:
            comfortTag = nil
        }
        
        print("\(comfortTag!) button clicked")
    }
    
    @IBAction func touchModeButton(_ sender: UIButton) {
        print("Mode button clicked")
    }

}
