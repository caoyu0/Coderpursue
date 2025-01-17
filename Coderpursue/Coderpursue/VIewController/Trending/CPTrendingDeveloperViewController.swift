//
//  CPTrendingDeveloperViewController.swift
//  Coderpursue
//
//  Created by WengHengcong on 3/10/16.
//  Copyright © 2016 JungleSong. All rights reserved.
//

import UIKit
import Moya
import Foundation
import MJRefresh
import ObjectMapper
import SwiftDate


public enum CPUserActionType:String {
    case Follow = "watch"
    case Repos = "star"
    case Following = "fork"
}


class CPTrendingDeveloperViewController: CPBaseViewController {

    @IBOutlet weak var developerInfoV: CPDeveloperInfoView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var followBtn: UIButton!
    
    var developer:ObjUser?
    var devInfoArr = [[String:String]]()
    
    var actionType:CPUserActionType = .Follow
    var followed:Bool = false
    
    // 顶部刷新
    let header = MJRefreshNormalHeader()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dvc_customView()
        dvc_setupTableView()
        dvc_updateViewContent()
        dvc_getUserinfoRequest()
        self.navigationController!.navigationBar.topItem?.title = ""

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let username = developer!.name {
            self.title = username
        }else{
            self.title = developer!.login!
        }
        dvc_checkUserFollowed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 顶部刷新
    func headerRefresh(){
        print("下拉刷新")
        
    }
    
    func dvc_customView(){

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.view.backgroundColor = UIColor.viewBackgroundColor()
        self.navigationItem.leftBarButtonItem?.title = "Back"

        developerInfoV.userActionDelegate = self
        
        if(developer!.login == UserInfoHelper.sharedInstance.user?.name){
            followBtn.hidden = true
        }else{
            followBtn.hidden = false
        }
        followBtn.layer.cornerRadius = 5
        followBtn.layer.masksToBounds = true
        followBtn.addTarget(self, action: "dvc_followAction", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    func dvc_setupTableView() {
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .None
        self.tableView.backgroundColor = UIColor.viewBackgroundColor()
        self.tableView.allowsSelection = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 下拉刷新
        header.setTitle("Pull down to refresh", forState: .Idle)
        header.setTitle("Release to refresh", forState: .Pulling)
        header.setTitle("Loading ...", forState: .Refreshing)
        header.setRefreshingTarget(self, refreshingAction: Selector("headerRefresh"))
        // 现在的版本要用mj_header
//        self.tableView.mj_header = header
        
    }
    
    func dvc_updateViewContent() {
        
        if(followed){
            followBtn.setTitle("Unfollow", forState: .Normal)
        }else{
            followBtn.setTitle("Follow", forState: .Normal)
        }
        
        if(developer==nil){
            return
        }
        
        devInfoArr.removeAll()
        
        if let joinTime:String = developer!.created_at {
            let ind = joinTime.startIndex.advancedBy(10)
            let subStr = joinTime.substringToIndex(ind)
            let join = "Joined on "+subStr
            let joinDic:[String:String] = ["img":"octicon_time_25","desc":join,"discolsure":"false"]
            devInfoArr.append(joinDic)
        }
        
        if let location:String = developer!.location {
            let locDic:[String:String] = ["img":"octicon_loc_25","desc":location,"discolsure":"false"]
            devInfoArr.append(locDic)
        }
        
        if let company = developer!.company {
            let companyDic:Dictionary = ["img":"octicon_org_25","desc":company,"discolsure":"false"]
            devInfoArr.append(companyDic)
        }
        
        developerInfoV.developer = developer
        self.tableView.reloadData()
    }
    
    func dvc_followAction() {
        
        if(followBtn.currentTitle == "Follow"){
            self.dvc_followUserRequest()
        }else if(followBtn.currentTitle == "Unfollow"){
            self.dvc_unfolloweUserRequest()
        }
        
    }
    
    
    func dvc_checkUserFollowed() {
    
        let username = developer!.login!
        
        Provider.sharedProvider.request(.Follow(username:username) ) { (result) -> () in
            
            var success = true
            var message = "No data to show"
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            print(result)
            switch result {
            case let .Success(response):
                
                let statusCode = response.statusCode
                if(statusCode == CPHttpStatusCode.NoContent.rawValue){
                    self.followed = true
                }else{
                    self.followed = false
                }
                self.dvc_updateViewContent()
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                success = false
                CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                
            }
        }

    }
    
    func dvc_getUserinfoRequest(){
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let username = developer!.login!

        Provider.sharedProvider.request(.UserInfo(username:username) ) { (result) -> () in
            
            var success = true
            var message = "No data to show"
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            switch result {
            case let .Success(response):
                
                do {
                    if let result:ObjUser = Mapper<ObjUser>().map(try response.mapJSON() ) {
                        self.developer = result
                        self.dvc_updateViewContent()
                        
                    } else {
                        success = false
                    }
                } catch {
                    success = false
                    CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                }
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                success = false
                CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                
            }
        }
        
        
    }
    
    func dvc_followUserRequest(){
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let username = developer!.login!
        
        Provider.sharedProvider.request(.Follow(username:username) ) { (result) -> () in
            
            var success = true
            var message = "No data to show"
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            switch result {
            case let .Success(response):
                
                let statusCode = response.statusCode
                if(statusCode == CPHttpStatusCode.NoContent.rawValue){
                    self.followed = true
                    CPGlobalHelper.sharedInstance.showError("Follow Successful", view: self.view)

                }
                self.dvc_updateViewContent()
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                success = false
                CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                
            }
        }
        
        
    }

    
    func dvc_unfolloweUserRequest(){
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let username = developer!.login!
        
        Provider.sharedProvider.request(.Unfollow(username:username) ) { (result) -> () in
            
            var success = true
            var message = "No data to show"
            
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            
            switch result {
            case let .Success(response):
                
                let statusCode = response.statusCode
                if(statusCode == CPHttpStatusCode.NoContent.rawValue){
                    self.followed = false
                    CPGlobalHelper.sharedInstance.showError("Unollow Successful", view: self.view)

                }
                
                self.dvc_updateViewContent()
                
            case let .Failure(error):
                guard let error = error as? CustomStringConvertible else {
                    break
                }
                message = error.description
                success = false
                CPGlobalHelper.sharedInstance.showError(message, view: self.view)
                
            }
        }
        
        
    }

    
    
}

extension CPTrendingDeveloperViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return devInfoArr.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        let cellId = "CPDevUserInfoCellIdentifier"

        if (indexPath.section == 0){
            
            var cell = tableView .dequeueReusableCellWithIdentifier(cellId) as? CPDevUserInfoCell
            if cell == nil {
                cell = (CPDevUserInfoCell.cellFromNibNamed("CPDevUserInfoCell") as! CPDevUserInfoCell)
            }
            
            //handle line in cell
            if row == 1 {
                cell!.topline = true
            }
            
            if (row == devInfoArr.count-1) {
                cell!.fullline = true
            }else {
                cell!.fullline = false
            }
            cell!.duic_fillData(devInfoArr[row])
            
            return cell!;
        }
        
        var cell = tableView .dequeueReusableCellWithIdentifier(cellId) as? CPDevUserInfoCell
        if cell == nil {
            cell = (CPDevUserInfoCell.cellFromNibNamed("CPDevUserInfoCell") as! CPDevUserInfoCell)
        }
        
        //handle line in cell
        if row == 0 {
            cell!.topline = true
        }
        if (row == 1) {
            cell!.fullline = true
        }
        
        return cell!;
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (section == 0){
            return nil
        }
        let view = UIView.init(frame: CGRectMake(0, 0, self.view.width, 10))
        view.backgroundColor = UIColor.viewBackgroundColor()
 
        return view
    }
    
}

extension CPTrendingDeveloperViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0){
            return 0
        }
        return 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 44
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //repos_url
    }
    
}

extension CPTrendingDeveloperViewController:UserProfileActionProtocol {
    
    
    func viewFollowAction() {
        actionType = .Follow
        segueGotoViewController()
    }
    
    func viewReposAction() {
        actionType = .Repos
        segueGotoViewController()
    }
    
    func viewFollowingAction() {
        actionType = .Following
        segueGotoViewController()
    }
    
    
    func segueGotoViewController() {
        
        if (!UserInfoHelper.sharedInstance.isLoginIn){
            CPGlobalHelper.sharedInstance.showError("Please first login in", view: self.view)
            return
        }
        
        switch(actionType){
        case .Follow:
            let uname = developer!.login
            let dic:[String:String] = ["uname":uname!,"type":"follower"]
            self.performSegueWithIdentifier(SegueUserToFollower, sender: dic)
            
        case .Repos:
            
            let uname = developer!.login
            let dic:[String:String] = ["uname":uname!,"type":"myrepositories"]
            self.performSegueWithIdentifier(SegueUserToRepository, sender: dic)

        case .Following:
            let uname = developer!.login
            let dic:[String:String] = ["uname":uname!,"type":"following"]
            self.performSegueWithIdentifier(SegueUserToFollowing, sender: dic)

        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if (segue.identifier == SegueUserToRepository){
            
            let reposVC = segue.destinationViewController as! CPReposViewController
            reposVC.hidesBottomBarWhenPushed = true
            
            let dic = sender as? [String:String]
            if (dic != nil) {
                reposVC.dic = dic!
                reposVC.username = dic!["uname"]
                reposVC.viewType = dic!["type"]
            }
            
        }else if(segue.identifier == SegueUserToFollowing){
            
            let followVC = segue.destinationViewController as! CPFollowersViewController
            followVC.hidesBottomBarWhenPushed = true
            
            let dic = sender as? [String:String]
            if (dic != nil) {
                followVC.dic = dic!
                followVC.username = dic!["uname"]
                followVC.viewType = dic!["type"]
            }
            
        }else if(segue.identifier == SegueUserToFollower){
            
            let followVC = segue.destinationViewController as! CPFollowersViewController
            followVC.hidesBottomBarWhenPushed = true
            
            let dic = sender as? [String:String]
            if (dic != nil) {
                followVC.dic = dic!
                followVC.username = dic!["uname"]
                followVC.viewType = dic!["type"]
            }
            
        }
    }

    
    
}



