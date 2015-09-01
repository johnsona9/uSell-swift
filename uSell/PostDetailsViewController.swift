//
//  PostDetailsViewController.swift
//  uSell
//
//  Created by Adam Johnson on 8/10/15.
//
//

import UIKit
import Parse
import JSQMessagesViewController

class PostDetailsViewController: UIViewController {
    
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editionLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    var post:PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleColors()
        let title = self.post["postTitle"] as? String
        let edition = self.post["postEdition"] as? String
        let department = self.post["postDepartment"] as? String
        let cost = self.post["postCost"] as? String
        let author = self.post["postAuthor"] as? String
        self.titleLabel.text = "Title: \(title!)"
        self.editionLabel.text = "Edition: \(edition!)"
        self.departmentLabel.text = "Department: \(department!)"
        self.costLabel.text = "Cost: \(cost!)"
        self.authorLabel.text = "By: \(author!)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chatButtonTouch(sender: AnyObject) {
        var userQuery = PFUser.query()?.whereKey("objectId", equalTo: PFUser.currentUser()!.objectId!)
        userQuery?.getFirstObjectInBackgroundWithBlock({ (user, error) -> Void in
            if error == nil {
                if let currentUser : PFUser = user as? PFUser {
                    if currentUser.objectForKey("emailVerified") as! Bool {
                        self.performSegueWithIdentifier("postDetailsToChatSegue", sender: self)
                    } else {
                        GlobalConstants.AlertMessage.displayAlertMessage("You can't chat until you've verified your email!", view: self)
                    }
                }
            }
            else {
                GlobalConstants.AlertMessage.displayAlertMessage("There was an error finding you in our database, please try again", view: self)
            }
        })
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "postDetailsToChatSegue" {
            let reachability = Reachability.reachabilityForInternetConnection()
            if (reachability.isReachable()) {
                
                var svc = segue.destinationViewController as? ChatViewController
                
                var query = PFQuery(className: "chatRoom")
                query.whereKey("user1", equalTo: PFUser.currentUser()!)
                query.whereKey("user2", equalTo: self.post["poster"]!)
                var inverseQuery = PFQuery(className: "chatRoom")
                inverseQuery.whereKey("user2", equalTo: PFUser.currentUser()!)
                inverseQuery.whereKey("user1", equalTo: self.post["poster"]!)
                var queryCombined = PFQuery.orQueryWithSubqueries([query, inverseQuery])
                queryCombined.includeKey("user1")
                queryCombined.includeKey("user2")
                
                queryCombined.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
                    if object == nil && error != nil {
                        var newChatRoom = PFObject(className: "chatRoom")
                        newChatRoom.setObject(PFUser.currentUser()!, forKey: "user1")
                        newChatRoom.setObject(self.post["poster"]!, forKey: "user2")
                        
                        svc!.chatRoom = newChatRoom
                        newChatRoom.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if error == nil {
                                svc!.loadChatRoom()
                            }
                        })
                        
                    } else if error == nil {
                        if object != nil {
                            println("expected chatroom")
                            svc!.chatRoom = object!
                            svc!.loadChatRoom()
                        }
                    }
                })
                
            } else {
                GlobalConstants.AlertMessage.displayAlertMessage("You aren't connected to the internect, please check your connection and try again.", view: self)
            }
            
        }
    }
    
    private func handleColors() {
        self.view.backgroundColor = GlobalConstants.Colors.backgroundColor
        self.titleLabel.textColor = GlobalConstants.Colors.goldColor
        self.editionLabel.textColor = GlobalConstants.Colors.goldColor
        self.departmentLabel.textColor = GlobalConstants.Colors.goldColor
        self.costLabel.textColor = GlobalConstants.Colors.goldColor
        self.chatButton.setTitleColor(GlobalConstants.Colors.goldColor, forState: UIControlState.Normal)
        self.authorLabel.textColor = GlobalConstants.Colors.goldColor
    }
    

}
