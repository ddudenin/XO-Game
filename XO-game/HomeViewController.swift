//
//  HomeViewController.swift
//  XO-game
//
//  Created by Дмитрий Дуденин on 28.06.2021.
//  Copyright © 2021 plasmon. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func vsPlayerButtonHandler(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: .none)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "gameScreen") as? GameViewController else { return }
        vc.vsAI = false
        self.present(vc, animated: true, completion: .none)
    }
    
    @IBAction func vsComputerButtonHandler(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: .none)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "gameScreen") as? GameViewController else { return }
        vc.vsAI = true
        self.present(vc, animated: true, completion: .none)
    }
    
}
