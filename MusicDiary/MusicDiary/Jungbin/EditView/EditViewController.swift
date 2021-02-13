//
//  EditViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/02/07.
//

import UIKit
import Firebase

var newCD = ContentData()

class EditViewController: UIViewController, SendDataDelegate {
    func sendData(data: MusicStruct) {
        getMusic = data
        
        DispatchQueue.global().async { let data = try? Data(contentsOf: self.getMusic.musicCoverUrl!)
            DispatchQueue.main.async {
                self.imageVIew.image = UIImage(data: data!)
                self.titleLabel.text = self.getMusic.musicTitle
                self.artistLabel.text = self.getMusic.musicArtist
                newCD.musicCoverUrl = self.getMusic.musicCoverUrl!
            }
        }
        self.writeView.frame.origin.y = self.originY
        
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var imageVIew: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var writeView: UIView!
    var getMusic:MusicStruct!
    var originY:CGFloat!

    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        print("current Diary id: ", daily_currentDiaryID)
        print("current content id: ", currentContentID!)
       
        super.viewDidLoad()
        imageVIew.layer.cornerRadius = imageVIew.frame.width / 2
        imageVIew.clipsToBounds = true
        writeView.backgroundColor = UIColor(patternImage: UIImage(named: "Write_underBG")!)
        originY = self.writeView.frame.origin.y

        presentData()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification , object: nil)
        
    }
    @IBAction func tapSaveBtn(_ sender: Any) {
        let docRef = db.collection("Diary").document("\(daily_currentDiaryID)").collection("Contents").document("\(currentContentID!)")

        docRef.updateData( [
            "contentText":"\(textView.text!)",
            "musicArtist":"\(artistLabel.text!)",
            "musicCoverUrl":String(describing: newCD.musicCoverUrl!),
            "musicTitle":"\(titleLabel.text!)"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document updated with ID: \(docRef.documentID)")
            }
        }
        self.dismiss(animated: true)
        
    }
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func tapSearchBtn(_ sender: Any) {
        let board = UIStoryboard(name: "YujinStoryboard", bundle: nil)
        guard let vc = board.instantiateViewController(identifier: "SearchBoardView") as? SearchBoardViewController else {return}
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        delegate = self
    }
//MARK: 키보드 올라오고 내려올 때
    @objc func keyboardWillAppear(_ sender: NotificationCenter){
        self.writeView.frame.origin.y = self.originY
        self.writeView.frame.origin.y -= 190
    }
    @objc func keyboardWillDisappear(_ sender: NotificationCenter){
        self.writeView.frame.origin.y = 355
        }
    func presentData() {
        let docRef = db.collection("Diary").document("\(daily_currentDiaryID)").collection("Contents").document("\(currentContentID!)")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                newContent.musicCoverUrl = URL(string: (dataDescription!["musicCoverUrl"]! as? String)!)
                
                newCD.authorID = dataDescription!["authorID"] as? String
                newCD.conentText = dataDescription!["contentText"] as? String
                newCD.musicTitle = dataDescription!["musicTitle"] as? String
                newCD.musicArtist = dataDescription!["musicArtist"] as? String
                newCD.musicCoverUrl = URL(string: (dataDescription!["musicCoverUrl"]! as? String)!)
                newCD.date = dataDescription!["date"] as? Date
                self.titleLabel.text = newCD.musicTitle
                self.artistLabel.text = newCD.musicArtist
                self.textView!.text = newCD.conentText
                
                //print("Document data: ", newURL)
                
                DispatchQueue.global().async { let data = try? Data(contentsOf: newCD.musicCoverUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async { self.imageVIew.image = UIImage(data: data!) }
                }
                
            } else {
                print("Document does not exist")
            }
        }
        
        
    }
    
}
extension EditViewController: UITextViewDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.textView.resignFirstResponder()
        }
    func placeholderSetting() {
        textView.delegate = self // txtvReview가 유저가 선언한 outlet
        textView.text = "오늘의 감상, 기분, 일기를 기록하세요. 📝"
        textView.textColor = UIColor.lightGray
    }
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "오늘의 감상, 기분, 일기를 기록하세요. 📝"
            textView.textColor = UIColor.lightGray
        }
    }
}
