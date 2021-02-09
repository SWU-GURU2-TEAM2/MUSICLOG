//
//  DiarySettingViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/02/07.
//

import UIKit
import Firebase

class DiarySettingViewController: UIViewController, SendDataDelegate {
    func sendData(data: MusicStruct) {
            getMusic = data
            titleLabel.text = getMusic.musicTitle
            artistLabel.text = getMusic.musicArtist
            DispatchQueue.global().async { let data = try? Data(contentsOf: self.getMusic.musicCoverUrl!)
                DispatchQueue.main.async { self.imageView.image = UIImage(data: data!) }
            }          
            
    }
    
    let db = Firestore.firestore()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var diaryNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    var newDiaryData = DiaryStructure()
    var newMemberList: [UserStructure] = []
    var getMusic:MusicStruct!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        presentDiaryDataForSetting()
        

    }
    
    @IBAction func goSearchBtn(_ sender: Any) {
        let board = UIStoryboard(name: "YujinStoryboard", bundle: nil)
        guard let vc = board.instantiateViewController(identifier: "SearchView") as? SearchViewController else {return}
        self.present(vc, animated: true, completion: nil)
        vc.delegate = self
    }
    
    @IBAction func editDairyName(_ sender: Any) {
        
        let alert = UIAlertController(title: "다이어리 이름 변경", message: "변경할 이름을 입력해 주세요.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.diaryNameLabel.text
        }//addTextField
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let changedName = alert.textFields![0].text, changedName != ""{
                let docRef = self.db.collection("Diary").document("\(currentDairyId)")
                docRef.updateData([
                    "diaryName": "\(changedName)"
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                self.diaryNameLabel.text = changedName
            }//changedName
        }//handler
        ))//addAction
        self.present(alert, animated: false, completion: nil)
        
    }
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func tapAddUserBtn(_ sender: Any) {
    }
    func presentDiaryDataForSetting() { // 다이어리 '한개!!!' 의 다어어리 정보 가져오는거임!!!
        var docRef = db.collection("Diary").document("\(currentDairyId)")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                //newContent.musicCoverUrl = URL(string: (dataDescription!["musicCoverUrl"]! as? String)!)

                self.newDiaryData.diaryName = dataDescription!["diaryName"] as? String
                self.newDiaryData.diaryMusicTitle = dataDescription!["diaryMusicTitle"] as? String
                self.newDiaryData.diaryMusicArtist = dataDescription!["diaryMusicArtist"] as? String
                self.newDiaryData.diaryImageUrl = URL(string: (dataDescription!["diaryImageUrl"]! as? String)!)
                self.newDiaryData.memberList = dataDescription!["memberList"] as? [String]

                print("new data: ", self.newDiaryData)
                
                
                for member in self.newDiaryData.memberList! {
                    self.db.collection("Users").document("\(member)").getDocument { (document, error) in
                        if let newdoc = document, ((document?.exists) != nil) {
                            let newDescription = newdoc.data()
                            self.newMemberList.append(UserStructure(
                                                        userName: newDescription!["userName"] as? String,
                                                        userId: newDescription!["userID"] as? String,
                                                        userImage: URL(string: (newDescription!["userImage"]! as? String)!),
                                                        userDiaryList: newDescription!["userDiaryList"]! as? [String]))
                            print("new member list: ", self.newMemberList)
                            self.tableView.reloadData()

                        } else{
                            print("멤버못찾음")
                        }

                    }

                }
                
                
                DispatchQueue.global().async { let data = try? Data(contentsOf: self.newDiaryData.diaryImageUrl!)
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data!)
                        self.titleLabel.text = self.newDiaryData.diaryMusicTitle!
                        self.artistLabel.text = self.newDiaryData.diaryMusicArtist!
                        self.diaryNameLabel.text = self.newDiaryData.diaryName!
                    }
                }
                // 여기까지

            } else {
                print("Document does not exist")
            }
        }
    }
}
extension DiarySettingViewController:  UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newMemberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! UserTableViewCell
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2
        cell.profileImageView.clipsToBounds = true
        cell.userNameLabel.text = newMemberList[indexPath.row].userName
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        if let url = self.newMemberList[indexPath.row].userImage {
            do {
                let data = try Data(contentsOf: url)
                cell.profileImageView.image = UIImage(data: data)
                
            } catch {
            }
        }
        
        
        return cell
    }
    
    
}
