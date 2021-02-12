//
//  MainView.swift
//  MusicDiary
//
//  Created by 강예원 on 2021/01/28.
//

import UIKit
import ScalingCarousel
import FirebaseFirestore

var currentDairyId = ""

class MainVC:UIViewController {
    let db = Firestore.firestore()
    var diaryData: [DiaryStructure] = []
    var getDiaryList = [String]()
    
    //MARK: ---------------------IBDulet
    
    @IBOutlet weak var mainCarousel: ScalingCarouselView!
    @IBOutlet weak var writeBtn: UIButton!
    
    @IBAction func moveToWrite(_ sender: UIButton) {
        
        //center Diary 해당 날짜에 콘텐츠 있으면 안보이게
        let vc = UIStoryboard(name: "JungbinStoryboard", bundle: nil).instantiateViewController(identifier: "WriteView")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion:  nil)
    }
    @IBAction func moveToSetting(_ sender: UIButton) {
        let vc = UIStoryboard(name: "YujinStoryboard", bundle: nil).instantiateViewController(identifier: "appSettingView")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion:  nil)
    }
    //MARK: ----------------viewDidLoad

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadDiaryData()
        self.mainCarousel.reloadData()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //Users에서 diaryList 필드 읽어오기
        
    }
    func loadDiaryData(){
        self.diaryData = []
        db.collection("Users").document(currentUID).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()
                self.getDiaryList = (dataDescription!["userDiaryList"] as? [String])!
                print("diary list : ", self.getDiaryList)
                //Diary에서 getDiaryList랑 맞는 거 읽어오기
                for currentDId in self.getDiaryList {
                    let docRef = self.db.collection("Diary").document("\(currentDId)")
                    var newDiaryData = DiaryStructure()
                    docRef.getDocument { [self] (document, error) in
                        if let document = document, document.exists {
                            let dataDescriptions = document.data()
                            newDiaryData.diaryId = dataDescriptions!["diaryID"] as? String
                            newDiaryData.diaryName = dataDescriptions!["diaryName"] as? String
                            newDiaryData.diaryMusicTitle = dataDescriptions!["diaryMusicTitle"] as? String
                            newDiaryData.diaryMusicArtist = dataDescriptions!["diaryMusicArtist"] as? String
                            newDiaryData.diaryImageUrl = URL(string: (dataDescriptions!["diaryImageUrl"]! as? String)!)
                            newDiaryData.date = Date(timeIntervalSince1970: TimeInterval((dataDescriptions!["date"] as! Timestamp).seconds))
                            newDiaryData.memberList = dataDescriptions!["memberList"] as? [String]
                            
                            self.diaryData.append(newDiaryData)
                            self.diaryData.sort {$0.date! < $1.date!}
                            //self.mainCarousel.reloadData()//date에 따라 정렬
                        } else {
                            print("Document does not exist")
                            
                        }
                        self.mainCarousel.reloadData()
                        let currentCenterIndex = 0
                        let oneDiaryID = self.diaryData[currentCenterIndex]
                        currentDairyId = oneDiaryID.diaryId!
                        hideWrite(date: Date())
                        
                    }
                }
            }
        }
    }
    
    //MARK: --------- ADD Diary
    
    @IBAction func addDiary(_ sender: UIButton) {
        //firebase에 다이어리 증가 + 유저 다이어리 리스트에도 추가 됨
        var ref: DocumentReference? = nil
        let date = Date()
        ref = self.db.collection("Diary").addDocument(data: [
            "diaryImageUrl":"https://i.imgur.com/JAMAE6A.png",
            "diaryName":"New Diary",
            "diaryMusicTitle":"",
            "diaryMusicArtist":"",
            "memberList":[currentUID],
            "date":date,
            "diaryID":""
        ]){ err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                
                //Diary 필드에 새 다이어리 documentID update
                self.db.collection("Diary").document(ref!.documentID).updateData(["diaryID":ref!.documentID])
                //Users diaryList update
                self.db.collection("Users").document(currentUID).updateData(["userDiaryList": FieldValue.arrayUnion([ref!.documentID])])
                self.loadDiaryData()
 //               self.mainCarousel.reloadData()
//                self.hideWrite(date: Date())
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        mainCarousel.deviceRotated()
    }
    //MARK: -----------------------Func
    func hideWrite (date:Date) {
        var author:String = ""
        let calendar = Calendar.current
        db.collection("Diary").document("\(currentDairyId)").collection("Contents").whereField("date", isGreaterThanOrEqualTo: calendar.startOfDay(for: date)).whereField("date", isLessThan: calendar.startOfDay(for: date)+86400).whereField("authorID", isEqualTo: "\(currentUID)").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let getContent = document.data()
                    author = getContent["authorID"] as! String
                }
                if author == "" {
                    //일기 없음
                    DispatchQueue.main.async {
                        self.writeBtn.isHidden = false
                    }
                }
                else {
                    // 일기 있음
                    DispatchQueue.main.async {
                        self.writeBtn.isHidden = true
                    }
                }
            }
        }
    }
}

//MARK: ------------------dateFormat

func dateFormat(date:Date) -> String {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = "yyyy년 MM월 dd일"
    let result = dateFormater.string(from: date)
    return result
}

// MARK: ---------------------MainCell

class MainCell: ScalingCarouselCell {
    @IBOutlet weak var mainDiaryImaage: UIImageView!
    @IBOutlet weak var mainDiaryName: UILabel!
    @IBOutlet weak var mainStartDate: UILabel!
    @IBOutlet weak var mainMemberInfo: UIImageView!
    override func prepareForReuse() {
        super.prepareForReuse()
        mainDiaryImaage.image = nil
    }
}

typealias CarouselDatasource = MainVC
extension CarouselDatasource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diaryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let carouselCell = collectionView.dequeueReusableCell(withReuseIdentifier: "carouselCell", for: indexPath) as! MainCell
        carouselCell.mainDiaryName.text = diaryData[indexPath.row].diaryName
        
        let start_date = dateFormat(date: self.diaryData[indexPath.row].date!)
        carouselCell.mainStartDate.text = start_date
        carouselCell.mainDiaryImaage.image = nil
        //이미지 넣기
        carouselCell.mainDiaryImaage.layer.cornerRadius = carouselCell.mainDiaryImaage.frame.width / 2
        carouselCell.mainDiaryImaage.clipsToBounds = true
        do {
            try carouselCell.mainDiaryImaage.image = UIImage(data: try Data(contentsOf: self.diaryData[indexPath.row].diaryImageUrl!))
            DispatchQueue.global().async { let data = try? Data(contentsOf: self.diaryData[indexPath.row].diaryImageUrl!)
                DispatchQueue.main.async { carouselCell.mainDiaryImaage.image = UIImage(data: data!) }
            }
        } catch  {        }
        
        //Share? Single?
        let memberList = diaryData[indexPath.row].memberList!.count
        if memberList >= 2 {
            carouselCell.mainMemberInfo.image = UIImage(named: "ShareDiary.png")
        } else {
            carouselCell.mainMemberInfo.image = UIImage(named: "SingleDiary.png")
        }
        
        carouselCell.setNeedsLayout()
        carouselCell.layoutIfNeeded()
        
        return carouselCell
    }
}

typealias CarouselDelegate = MainVC
extension MainVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let currentCenterIndex = mainCarousel.currentCenterCellIndex?.row else { return }
        //center Cell 의 documentID 저장
        let oneDiaryID = self.diaryData[currentCenterIndex]
        currentDairyId = oneDiaryID.diaryId!
        hideWrite(date: Date())
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "JungbinStoryboard", bundle: nil).instantiateViewController(identifier: "dailyView")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion:  nil)
        
    }
}

private typealias ScalingCarouselFlowDelegate = MainVC
extension ScalingCarouselFlowDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
