//
//  WriteViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/01/31.
//

import UIKit
import Firebase

var newContent = ContentData(authorID: "\(currentUID)", conentText: "", musicTitle: "", musicArtist: "", musicCoverUrl: URL(fileURLWithPath: "https://"), date: Date())

class WriteViewController:UIViewController, SendDataDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var underView: UIView!
    @IBOutlet weak var topView: UIView!
    var getMusic:MusicStruct!
    var originY:CGFloat!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        placeholderSetting()
        underView.backgroundColor = UIColor(patternImage: UIImage(named: "Write_underBG")!)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(_:)), name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        originY = self.underView.frame.origin.y
    }
    
    @IBAction func tapSaveBtn(_ sender: Any) {
        newContent.conentText = textView.text
        
        // 테스트 용
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.tempDiary.append(newContent)
        
        // 데이터 firebase에 저장
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        print("newContent in Save: ", newContent)
        ref = db.collection("Diary/\(currentDairyId)/Contents").addDocument(data: [
            "authorID": "\(newContent.authorID!)",
            "contentText":"\(newContent.conentText!)",
            "date":newContent.date!,
            "musicArtist":"\(newContent.musicArtist!)",
            "musicCoverUrl":String(describing: newContent.musicCoverUrl!),
            "musicTitle":"\(newContent.musicTitle!)"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        self.dismiss(animated: true)
        
    }
//MARK: goSearchBtn
    
    @IBAction func goSearchBtn(_ sender: Any) {
        let board = UIStoryboard(name: "YujinStoryboard", bundle: nil)
        guard let vc = board.instantiateViewController(identifier: "SearchBoardView") as? SearchBoardViewController else {return}
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
        delegate = self
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true)

    }
    
  
//MARK: sendData
    func sendData(data: MusicStruct) {
        getMusic = data
        print(getMusic)
        titleLabel.text = getMusic.musicTitle
        artistLabel.text = getMusic.musicArtist
        DispatchQueue.global().async { let data = try? Data(contentsOf: self.getMusic.musicCoverUrl!)
            DispatchQueue.main.async { self.imageView.image = UIImage(data: data!)
                
            }
        }

        self.viewDidLoad()
        self.underView.frame.origin.y = self.originY

        newContent.musicArtist = getMusic.musicArtist
        newContent.musicTitle = getMusic.musicTitle
        newContent.musicCoverUrl = getMusic.musicCoverUrl
        
        
    }
//MARK: 키보드 올라오고 내려올 때
    @objc func keyboardWillAppear(_ sender: NotificationCenter){
        self.underView.frame.origin.y = self.originY
        self.underView.frame.origin.y -= 190
    }
    @objc func keyboardWillDisappear(_ sender: NotificationCenter){
        self.underView.frame.origin.y = 353
    }
}
//MARK: 텍스트뷰 델리게이트
extension WriteViewController: UITextViewDelegate {
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
