//
//  DiarlyViewFuncs.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/02/10.
//

import UIKit

extension DailyViewController {
    func getContentsListForDaily(date: Date) {
        
        let calendar = Calendar.current
        currentContentData.musicTitle = ""
        
        // 다이어리내용 불러오기
        db.collection("Diary").document("\(daily_currentDiaryID)").collection("Contents") .whereField("date", isGreaterThanOrEqualTo: calendar.startOfDay(for: date)).whereField("date", isLessThan: calendar.startOfDay(for: date)+86400).whereField("authorID", isEqualTo: "\(currentotherUserID)").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let getContent = document.data()
                    currentContentData = ContentData(
                        authorID: getContent["authorID"] as! String,
                        conentText: getContent["contentText"] as? String,
                        musicTitle: getContent["musicTitle"] as! String,
                        musicArtist: getContent["musicArtist"] as! String,
                        musicCoverUrl: URL(string: (getContent["musicCoverUrl"]! as? String)!),
                        date: getContent["date"] as? Date)
                    currentContentID = document.documentID
                    
                }
                print("today content list: ", currentContentData)
                if currentContentData.musicTitle == "" { //일기 없음
                    
                    DispatchQueue.main.async {
                        self.noDataLabel.alpha = 1
                        self.titleLabel.alpha = 0
                        self.goDetailBtn.alpha = 0
                        self.goDetailBtn.isEnabled = false
                        self.imageView.alpha = 0
                    }
                }
                else {
                    DispatchQueue.global().async { let data = try? Data(contentsOf: currentContentData.musicCoverUrl!) // 일기 있음
                        DispatchQueue.main.async {
                            self.noDataLabel.alpha = 0
                            self.goDetailBtn.isEnabled = true
                            self.goDetailBtn.alpha = 1
                            self.titleLabel.alpha = 1
                            self.imageView.alpha = 1
                            self.titleLabel.text = currentContentData.conentText
                            self.imageView.image = UIImage(data: data!)
                            
                        }
                    }
                    
                }
            }
        }
    }
    func currentSelectedUserName(){
        let docRef = db.collection("Users").document("\(currentotherUserID)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("success")
                let dbName = document.get("userName")
                self.nameLabel.text = dbName as? String
            } else {
                print("no name")
            }
        }
    }
    
    func presentUserList() { // 다이어리 '한개!!!' 의 다어어리 정보 가져오는거임!!!
        newMemberList = []
        let docRef = db.collection("Diary").document("\(daily_currentDiaryID)")
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.newMemberIDList = (dataDescription!["memberList"] as? [String])!
                for member in self.newMemberIDList {
                    self.db.collection("Users").document("\(member)").getDocument { (document, error) in
                        if let newdoc = document, ((document?.exists) != nil) {
                            let newDescription = newdoc.data()
                            self.newMemberList.append(UserStructure(
                                                        userName: newDescription!["userName"] as? String,
                                                        userId: newDescription!["userID"] as? String,
                                                        userImage: URL(string: (newDescription!["userImage"]! as? String)!),
                                                        userDiaryList: newDescription!["userDiaryList"]! as? [String]))
                            self.newMemberList.sort{$0.userName! < $1.userName!} 
                            self.collectionView.reloadData()
                            
                        } else{
                            print("멤버못찾음")
                        }
                        
                    }
                    
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
}
