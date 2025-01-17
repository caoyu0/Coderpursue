//
//  CPMesNotificationCell.swift
//  Coderpursue
//
//  Created by WengHengcong on 3/7/16.
//  Copyright © 2016 JungleSong. All rights reserved.
//

import UIKit
import SwiftDate

class CPMesNotificationCell: CPBaseViewCell {

    @IBOutlet weak var typeImageV: UIImageView!
    
    @IBOutlet weak var notificationLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var reposBtn: UIButton!
    
    var noti:ObjNotification? {
        
        didSet {
            notiCell_fillData()
        }
    }
    
    
    override func customCellView() {
  
        //test 
        //if you want to change position or size by set frame property,you first disable autolayout.
//        typeImageV.frame = CGRectMake(50, 10, 44, 44);

    }
    
    func notiCell_fillData() {
        
        let notiType:SubjectType = SubjectType( rawValue: (noti!.subject!.type!) )!
        
        switch(notiType) {
        case .Issue:
            typeImageV.image = UIImage(named:"octicon_issue_25")
        case .PullRequest:
            typeImageV.image = UIImage(named:"octicon_pull_request_25")
        case .Release:
            typeImageV.image = UIImage(named:"coticon_tag_25")
        }
        
        
        notificationLabel.text = noti!.subject!.title
        reposBtn.setTitle(noti!.repository!.name, forState: .Normal)
        
        //time
        let updateAt:NSDate = noti!.updated_at!.toDate(DateFormat.ISO8601)!
        timeLabel.text = updateAt.toRelativeString(abbreviated: false, maxUnits:1)!+" ago"
    }
    

}
