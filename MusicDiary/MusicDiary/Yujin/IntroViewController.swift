//
//  IntroViewController.swift
//  MusicDiary
//
//  Created by 강유진 on 2021/01/31.
//

import UIKit
import FirebaseUI
import SwiftyGif
import FirebaseFirestore

var currentUID = ""

class IntroViewController: UIViewController, FUIAuthDelegate, UIGestureRecognizerDelegate {
    
    //values
    @IBOutlet weak var logoImageView: UIImageView! //logoImageView
    @IBOutlet weak var swipeLable: UILabel! //swipeLabel
    let authUI = FUIAuth.defaultAuthUI() //authUI
    let db = Firestore.firestore() //db
    let storage = Storage.storage() //storage
    var handle: AuthStateDidChangeListenerHandle! //handle
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //swipeGestureControl
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestured(_:)))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizer.Direction.up
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }//viewDidLoad
    
    //viewDidDisappear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //firebase auth listener 삭제
        Auth.auth().removeStateDidChangeListener(handle)
    }//viewDidDisappear
    
    //swipeGesture
    @objc func swipeGestured(_ sender: Any) {
        print("swiped")
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            //만약 로그인 했다면
            if let currentUser = auth.currentUser {
                //currentUser 정보 넘겨주기
                //로그인한 유저 -> 기존 사용자 체크, 다음 뷰로 넘어감
                let ad = UIApplication.shared.delegate as? AppDelegate
                //appDelegate에 저장
                ad?.currentUID = currentUser.uid
                currentUID = currentUser.uid
                let docRef = self.db.collection("Users").document("\(currentUser.uid)")
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                    } else {
                        print("User does not exist")
                        let storageRef = self.storage.reference()
                        let imageRef = storageRef.child("progileImages/Icon material-person@3x.png")
                        self.db.collection("Users").document("\(currentUser.uid)").setData(["userDiaryList" : [],
                             "userID" : "\(currentUser.uid)",
                             "userImage" : "\(imageRef.fullPath)",
                             "userName" : "\(currentUser.displayName!)"])
                        print("UserDataSaved")
                    }
                }
                
                let vc = UIStoryboard(name: "YujinStoryboard", bundle: nil).instantiateViewController(identifier: "appSettingView")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion:  nil)
            } else {
                //로그인 안한 유저 -> 로그인 화면이 뜸
                self.authUI!.delegate = self
                  let providers: [FUIAuthProvider] = [
                  FUIGoogleAuth()
                ]
                self.authUI!.providers = providers
                let authViewController = self.authUI!.authViewController()
                authViewController.modalPresentationStyle = .fullScreen
                authViewController.setNavigationBarHidden(true, animated: false)
                self.present(authViewController, animated: true, completion: nil)
            }//if else
        }//handle
    }//swipeGestured
}
