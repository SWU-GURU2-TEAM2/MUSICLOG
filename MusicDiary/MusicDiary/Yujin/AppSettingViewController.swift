//
//  AppSettingView.swift
//  MusicDiary
//
//  Created by 강유진 on 2021/02/07.
//

import UIKit
import Photos
import FirebaseUI
import FirebaseFirestore

class AppSettingViewController: UIViewController, SendDataDelegate {
  
    
    //values
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUID: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileImageOutline: UIImageView!
    let authUI = FUIAuth.defaultAuthUI()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let ad = UIApplication.shared.delegate as! AppDelegate
    var imagePicker: UIImagePickerController!
    
    //viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        //uidSetting
        userUID.text = currentUID
        //profileImageSetting
        profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        //profileImage tap action setting
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileTouched(_:)))
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        profileImage.isUserInteractionEnabled = true
        
        //userDataLoading
        let docRef = db.collection("Users").document("\(currentUID)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("success")
                let dbName = document.get("userName")
                self.userName.text = dbName as! String
                let dbStorageRef = document.get("userImage")!
                let url = URL(string: "\(dbStorageRef)")
                do {
                    let data = try Data(contentsOf: url!)
                    self.profileImage.image = UIImage(data: data)
                } catch {
                    print("noImage")
                }
            } else {
                print("Image does not exist")
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
        //self.ad.currentUID = ""
        currentUID = ""
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
    
    @IBAction func uidCopied(_ sender: Any) {
        UIPasteboard.general.string = currentUID
    }
    
}

extension AppSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func sendData(data: MusicStruct) {
        do {
            let cover = try Data(contentsOf: data.musicCoverUrl!)
            self.profileImage.image = UIImage(data: cover)
        } catch  {
            print("error")
        }
        let docRef = self.db.collection("Users").document("\(currentUID)")
        docRef.updateData([
            "userImage": "\(data.musicCoverUrl!)"
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    @objc func profileTouched(_ sender: Any) {
        print("touched")
        let storageRef = storage.reference()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        actionSheet.addAction(actionCancel)
        let actionGallary = UIAlertAction(title: "찾기", style: .default) { (action) in
            let board = UIStoryboard(name: "YujinStoryboard", bundle: nil)
            guard let vc = board.instantiateViewController(identifier: "SearchBoardView") as? SearchBoardViewController else {return}
            self.present(vc, animated: true, completion: nil)
            delegate = self
            
        }
        actionSheet.addAction(actionGallary)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showGallary () {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("OKKKKKKKKKKKK")
        self.imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("no selectedImage")
            return
        }
        
        
    }//didFinishPickingMediaWithInfo
}
