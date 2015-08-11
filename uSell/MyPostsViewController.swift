//
//  MyPostsViewController.swift
//  uSell
//
//  Created by Adam Johnson on 8/10/15.
//
//

import UIKit
import Parse

class MyPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var postsList = [PFObject]()

    @IBOutlet weak var myPostsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getPosts()
        self.myPostsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        var rightItem:UIBarButtonItem = UIBarButtonItem(title: "New", style: .Plain, target: self, action: "newPostSegue")
        self.navigationItem.rightBarButtonItem = rightItem
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("myPostsToEditPostSegue", sender: indexPath)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.myPostsTableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        cell.textLabel?.text = postsList[indexPath.row]["postTitle"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.postsList.count
    }

    
    func newPostSegue() {
        self.performSegueWithIdentifier("myPostsToCreatePostSegue", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "myPostsToCreatePostSegue") {
            
        }
        else if (segue.identifier == "myPostsToEditPostSegue") {
            var svc = segue.destinationViewController as! EditPostViewController
            svc.initialObject = self.postsList[(sender as! NSIndexPath).row]
        }
        
    }

    private func getPosts() {
        var postsQuery = PFQuery(className: "post").whereKey("poster", equalTo: PFUser.currentUser()!)
        postsQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                if let postObjects = objects as? [PFObject] {
                    for post in postObjects {
                        self.postsList.append(post)
                    }
                    self.myPostsTableView.reloadData()
                }
            }
        }
        
    }

}