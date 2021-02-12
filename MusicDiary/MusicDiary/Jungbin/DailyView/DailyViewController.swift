//
//  DailyViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/01/31.
//

import UIKit
import FSCalendar
import Firebase


var currentDairyUserList:[String]!
var currentContentData = ContentData()
var currentContentID:String?
var currentOtehrUserID = currentUID
var events:[Date] = []

class DailyViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    var datesWithEvent = [Date(), Date()-86400]
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var goDetailBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nameLabel: UILabel!
    let db = Firestore.firestore()
    var newMemberList: [UserStructure] = []
    var newMemberIDList: [String] = []
    var result = 0
    override func viewWillAppear(_ animated: Bool) {
        
        presentUserList()
        getContentsListForDaily(date: Date())

        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadDateForCalendar()
        currentSelectedUserName()
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        noDataLabel.alpha = 0
        titleLabel.numberOfLines = 6
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.alpha = 0
        goDetailBtn.alpha = 0
        calendar.delegate = self
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleWeekendColor = .black
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.headerDateFormat = "MMM"
        calendar.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.backgroundColor = UIColor.white.withAlphaComponent(0)
        calendar.appearance.eventDefaultColor = .gray
        calendar.appearance.eventSelectionColor = .gray
        
    }
    
    @IBAction func goMain(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func goDetail(_ sender: Any) {
        print("go detail")
        
        
    }
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        return UIImage(contentsOfFile: "Daily_calendarHeader")
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.datesWithEvent.contains(date) {
            calendar.reloadData()
            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
        }
        calendar.reloadData()
        
        return [appearance.eventDefaultColor]
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 아래 그날의 글들 보여주기
        noDataLabel.alpha = 0
        self.getContentsListForDaily(date: date)
        
        
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if events.contains(date){
            print("result: ",self.result)
            return 1
        }
        else {
            print("result: ",self.result)
            return 0
        }
        
        
    }
    
//MARK: loadDateForCalendar()
    func loadDateForCalendar() {
        
        let calendar = Calendar.current
        currentContentData.musicTitle = ""
        DispatchQueue.global().sync {
            self.db.collection("Diary").document("\(currentDairyId)").collection("Contents").whereField("authorID", isEqualTo: "\(currentOtehrUserID)").getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            DispatchQueue.global().sync {
                                events = []
                                for document in querySnapshot!.documents {
                                    let getContent = document.data()
                                    events.append(calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval((getContent["date"] as! Timestamp).seconds))))
                                }
                                print("엘스 안에서 이벤트: ", events)
                                self.calendar.reloadData()
                                
                            }

                        }
                    
                    }
        }
        
    }
}


extension DailyViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.newMemberList.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentOtehrUserID = newMemberList[indexPath.row].userId!
        print("select id: ", currentOtehrUserID)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        getContentsListForDaily(date: Date())
        self.calendar.select(calendar.today)
        self.loadDateForCalendar()
        currentSelectedUserName()
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! UserCollectionViewCell
        cell.imageView.layer.cornerRadius = cell.imageView.frame.width / 2
        cell.imageView.clipsToBounds = true
        cell.imageView.image = nil
        
        DispatchQueue.global().async { let data = try? Data(contentsOf: self.newMemberList[indexPath.row].userImage!)
            DispatchQueue.main.async {
                cell.imageView.image = UIImage(data: data!)
            }
        }
        
        
        return cell
        
        
    }
    //좌우 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
