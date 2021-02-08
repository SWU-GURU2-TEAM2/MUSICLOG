//
//  AppSettingView.swift
//  MusicDiary
//
//  Created by 강유진 on 2021/02/07.
//

import UIKit
import FirebaseUI
import FirebaseFirestore

class AppSettingViewController: UIViewController {
    
    //values
    @IBOutlet weak var userName: UILabel!
    let authUI = FUIAuth.defaultAuthUI()
    let db = Firestore.firestore()
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = authUI?.auth?.currentUser
        let docRef = db.collection("Users").document("\(currentUser!.uid)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("success")
                let dbName = document.get("userName")
                self.userName.text = dbName as! String
            } else {
                print("Document does not exist")
            }
        }//docRef
    }//viewDidLoad
    
    //logOutAction
    @IBAction func logOutAction(_ sender: Any) {
        print("logOut")
        //로그아웃 시도
        do {
            try authUI?.signOut()
        } catch {
            print("logoutError")
        }
        let vc = UIStoryboard(name: "YujinStoryboard", bundle: nil).instantiateViewController(identifier: "IntroView")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion:  nil)
    }//logOutAction
    
    //chaneUserName
    @IBAction func changeUserName(_ sender: Any) {
        //alert으로 띄워서 이름 변경
        let alert = UIAlertController(title: "이름 변경", message: "변경할 이름을 입력해주세요.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.userName.text
        }//addTextField
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let changedName = alert.textFields![0].text, changedName != ""{
                let currentUser = self.authUI?.auth?.currentUser
                let docRef = self.db.collection("Users").document("\(currentUser!.uid)")
                docRef.updateData([
                    "userName": "\(changedName)"
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                self.userName.text = changedName
            }//changedName
        }//handler
        ))//addAction
        self.present(alert, animated: false, completion: nil)

    }//changeUserName
    
    
}
