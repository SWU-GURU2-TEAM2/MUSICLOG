//
//  ViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/01/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("open")
        let vc = UIStoryboard(name: "YujinStoryboard", bundle: nil).instantiateViewController(identifier: "IntroView")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion:  nil)
        print("wan")
    }
    

}

