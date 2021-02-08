//
//  DailyViewController.swift
//  MusicDiary
//
//  Created by 1v1 on 2021/01/31.
//

import UIKit
import FSCalendar
import Firebase

var currentDairyId = "IxLlj4mK2DKPIoBA9Qjp"

class DailyViewController: UIViewController, FSCalendarDelegate {
    
    var todayContentList:[ContentData] = [ContentData()]
    var datesWithEvent = [Date(), Date()-86400]
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var goDetailBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
        noDataLabel.alpha = 0
        titleLabel.numberOfLines = 6
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.alpha = 0
        goDetailBtn.alpha = 0
        calendar.delegate = self
        //calendar.appearance.backgroundColors =
        getContentsListForDaily(date: Date())
        
        calendar.appearance.titleDefaultColor = .black
        calendar.appearance.titleWeekendColor = .black
        // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.headerTitleColor = .black
        // 달력의 요일 글자 색깔
        calendar.appearance.weekdayTextColor = .black
        //년 월 custom
        calendar.appearance.headerDateFormat = "MMM"
        calendar.appearance.caseOptions = FSCalendarCaseOptions.weekdayUsesSingleUpperCase
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.backgroundColor = UIColor.white.withAlphaComponent(0)
    
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
        print("selected date: ", date)
        getContentsListForDaily(date: date)
        
        
    }
    
    func getContentsListForDaily(date: Date) {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        
        self.todayContentList = []
        // .whereField("date", isLessThan: calendar.startOfDay(for: date)+86400)
        db.collection("Diary").document("\(currentDairyId)").collection("Contents") .whereField("date", isGreaterThanOrEqualTo: calendar.startOfDay(for: date)).whereField("date", isLessThan: calendar.startOfDay(for: date)+86400).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    let getContent = document.data()
                    let newCD = ContentData(
                        authorID: getContent["authorID"] as! String,
                        conentText: getContent["contentText"] as! String,
                        musicTitle: getContent["musicTitle"] as! String,
                        musicArtist: getContent["musicArtist"] as! String,
                        musicCoverUrl: URL(string: (getContent["musicCoverUrl"]! as? String)!),
                        date: getContent["date"] as? Date)
                    self.todayContentList.append(newCD)
                    //print("\(document.documentID) => \(document.data())")
                    
                    
                }
                print("today content list: ", self.todayContentList)
                if self.todayContentList.count == 0 {
                    
                    DispatchQueue.main.async {
                        self.noDataLabel.alpha = 1
                        self.titleLabel.alpha = 0
                        self.goDetailBtn.alpha = 0
                        self.goDetailBtn.isEnabled = false
                        self.imageView.alpha = 0
                    }
                }
                else {
                    DispatchQueue.global().async { let data = try? Data(contentsOf: self.todayContentList[0].musicCoverUrl!)
                        DispatchQueue.main.async {
                            self.goDetailBtn.isEnabled = true
                            self.goDetailBtn.alpha = 1
                            self.titleLabel.alpha = 1
                            self.imageView.alpha = 1
                            self.titleLabel.text = self.todayContentList[0].conentText
                            self.imageView.image = UIImage(data: data!)
                            
                        }
                    }
                    
                }
            }
        }
        
    }
    
    
}
