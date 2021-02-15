//
//  DetailView.swift
//  MusicDiary
//
//  Created by 강예원 on 2021/02/06.
//

import UIKit
import FirebaseFirestore

class DetailVC:UIViewController {
    //var diaryID:String!
    //var contentId:String!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var singer: UILabel!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var contentText: UITextView!
    var contentData = [String]()
    let db = Firestore.firestore()
    //var contentData = [ContentData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let docRef = db.collection("Diary").document("IxLlj4mK2DKPIoBA9Qjp").collection("Contents").document("9G2Dh6BvPGmsJIynqWtv")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                self.contentData.append(dataDescription)
                //print(contentData[0]["contentText"])

            } else {
                print("Document does not exist")
            }

        }
                
    }
    
    //delete docunet
    @IBAction func deleteDoc(_ sender: UIButton) {
        let alertVC = UIAlertController(title: "Delete", message: "정말 삭제할까요?", preferredStyle: .alert)
        let action_cancel = UIAlertAction(title: "Cencel", style: .cancel, handler: nil)
        let action_delete = UIAlertAction(title: "Delete", style: .default) { (action) in
            do {
                self.db.collection("Diary").document("IxLlj4mK2DKPIoBA9Qjp").collection("Contents").document("ytGhBqaCnQAdq3feUqhI").delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            print("delete")
            self.dismiss(animated: true, completion: nil)
            } catch {
                
            }
        }
        alertVC.addAction(action_cancel)
        alertVC.addAction(action_delete)
        self.present(alertVC, animated: true, completion: nil)
    }
    
}

class DetailSub1VC: DetailVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
class DetailSub2VC: DetailVC {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
