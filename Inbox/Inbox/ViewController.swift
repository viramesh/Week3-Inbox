//
//  ViewController.swift
//  Inbox
//
//  Created by viramesh on 2/18/15.
//  Copyright (c) 2015 vbits. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    var mainViewOriginalCenter:CGPoint!
    var mainViewCurrentCenter:CGPoint!
    var mainViewPanGesture:UIPanGestureRecognizer!
    
    @IBOutlet weak var inboxScrollView: UIScrollView!
    @IBOutlet weak var feedView: UIView!
    @IBOutlet weak var messageViewContainer: UIView!
    @IBOutlet weak var messageView: UIImageView!
    var messageViewOriginalCenter: CGPoint!
    @IBOutlet weak var feedImageView: UIImageView!
    
    @IBOutlet weak var iconArchive: UIImageView!
    @IBOutlet weak var iconDelete: UIImageView!
    @IBOutlet weak var iconLater: UIImageView!
    @IBOutlet weak var iconList: UIImageView!
    var iconArchiveCenter:CGPoint!
    var iconDeleteCenter:CGPoint!
    var iconLaterCenter:CGPoint!
    var iconListCenter:CGPoint!
    var userAction:NSString!
    var tapGesture:UITapGestureRecognizer!
    
    @IBOutlet weak var listOptions: UIImageView!
    @IBOutlet weak var rescheduleOptions: UIImageView!
    
    var sidebarShown:Bool!
    var edgeGesture:UIScreenEdgePanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        inboxScrollView.contentSize = feedView.frame.size
        
        tapGesture = UITapGestureRecognizer(target: self, action: "onTapOptions:")
        
        sidebarShown = false;
        mainViewOriginalCenter = mainView.center
        
        edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        edgeGesture.edges = UIRectEdge.Left
        mainView.addGestureRecognizer(edgeGesture)
        
        mainViewPanGesture = UIPanGestureRecognizer(target: self, action: "onMainViewPan:")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPanMessage(sender: UIPanGestureRecognizer) {
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            messageViewOriginalCenter = messageView.center
            iconArchiveCenter = iconArchive.center
            iconDeleteCenter = iconDelete.center
            iconLaterCenter = iconLater.center
            iconListCenter = iconList.center
            userAction = ""
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            messageView.center.x = messageViewOriginalCenter.x + translation.x
            
            //message is dragged left
            if(translation.x < 0) {
                if(translation.x > -60) {
                    userAction = ""
                    iconLater.alpha = CGFloat(convertValue(fabsf(Float(translation.x)), 0, 60, 0, 1))
                }
                
                else if(translation.x > -250) {
                    userAction = "later"
                    iconLater.alpha = 1
                    iconLater.center.x = iconLaterCenter.x + translation.x + 60
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.messageViewContainer.backgroundColor = UIColor(red: 248/255, green: 231/255, blue: 28/255, alpha: 1)
                    })
                }
                
                else {
                    userAction = "list"
                    iconLater.alpha = 0
                    iconList.alpha = 1
                    iconList.center.x = iconListCenter.x + translation.x + 60
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.messageViewContainer.backgroundColor = UIColor(red: 184/255, green: 136/255, blue: 93/255, alpha: 1)
                    })
                }
            }
                
            //message is dragged right
            else {
                if(translation.x < 60) {
                    userAction = ""
                    iconArchive.alpha = CGFloat(convertValue(fabsf(Float(translation.x)), 0, 60, 0, 1))
                }
                    
                else if(translation.x < 250) {
                    userAction = "archive"
                    iconArchive.alpha = 1
                    iconArchive.center.x = iconArchiveCenter.x + translation.x - 60
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.messageViewContainer.backgroundColor = UIColor(red: 126/255, green: 211/255, blue: 33/255, alpha: 1)
                    })
                }
                    
                else {
                    userAction = "delete"
                    iconArchive.alpha = 0
                    iconDelete.alpha = 1
                    iconDelete.center.x = iconDeleteCenter.x + translation.x - 60
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.messageViewContainer.backgroundColor = UIColor(red: 187/255, green: 0/255, blue: 23/255, alpha: 1)
                    })
                }
            }
            
        }
        else if sender.state == UIGestureRecognizerState.Ended {

            UIView.animateWithDuration(0.4, delay:0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.iconArchive.alpha = 0
                self.iconDelete.alpha = 0
                self.iconLater.alpha = 0
                self.iconList.alpha = 0
                
                if(self.userAction=="later" || self.userAction=="list") {
                    self.messageView.center.x = self.messageViewOriginalCenter.x - self.messageView.frame.width
                }
                else if(self.userAction=="archive" || self.userAction=="delete") {
                    self.messageView.center.x = self.messageViewOriginalCenter.x + self.messageView.frame.width
                }
                else if(self.userAction == "") {
                    self.messageView.center = self.messageViewOriginalCenter
                }
                
            }, completion: { (Bool) -> Void in
               
                switch(self.userAction) {
                    case "later":
                        self.rescheduleOptions.hidden = false
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            self.rescheduleOptions.alpha = 1
                        })
                        self.rescheduleOptions.addGestureRecognizer(self.tapGesture)
                        break
                    
                    case "list":
                        self.listOptions.hidden = false
                        UIView.animateWithDuration(0.2, animations: { () -> Void in
                            self.listOptions.alpha = 1
                        })
                        self.listOptions.addGestureRecognizer(self.tapGesture)
                        break
                    
                    case "archive":
                        self.hideMessage()
                        break
                    
                    case "delete":
                        self.hideMessage()
                        break
                    
                default: break
                    
                }

            })
            
        }
       
    }
    
    func hideMessage() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            //move feed up which will hide the message
            self.feedImageView.center.y = self.feedImageView.center.y - 86
            
            }, completion: { (Bool) -> Void in
                //once message is hidden, reset the message
                self.messageViewContainer.backgroundColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
                self.messageView.center = self.messageViewOriginalCenter
                self.iconArchive.center = self.iconArchiveCenter
                self.iconDelete.center = self.iconDeleteCenter
                self.iconLater.center = self.iconLaterCenter
                self.iconList.center = self.iconListCenter
                
                //set a delay and show message after delay expires
                delay(2) {
                    UIView.animateWithDuration(0.4, animations: { () -> Void in
                        self.feedImageView.center.y = self.feedImageView.center.y + 86
                    })
                }
            })
    }
    
    func onTapOptions(sender: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.rescheduleOptions.alpha = 0
            self.listOptions.alpha = 0
        }) { (Bool) -> Void in
            self.rescheduleOptions.hidden = true
            self.listOptions.hidden = true
            self.hideMessage()
        }
        
    }
    
    func onEdgePan(sender: UIScreenEdgePanGestureRecognizer) {
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            mainViewCurrentCenter = mainView.center
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            mainView.center.x = mainViewCurrentCenter.x + translation.x
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            if(velocity.x > 0) {
                showSidebar()
            }
            else {
                hideSidebar()
            }
        }
    }
    
    func onMainViewPan(sender: UIPanGestureRecognizer) {
        var translation = sender.translationInView(view)
        var velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            mainViewCurrentCenter = mainView.center
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            if(translation.x < 0) {
                mainView.center.x = mainViewCurrentCenter.x + translation.x
            }
            else {
                mainView.center.x = mainViewCurrentCenter.x
            }
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            if(velocity.x > 0) {
                showSidebar()
            }
            else {
                hideSidebar()
            }
        }
        
    }
    
    @IBAction func toggleSidebar(sender: AnyObject) {
        if(!sidebarShown){
            showSidebar()
        }
        else {
            hideSidebar()
        }
    }
    
    func showSidebar() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.mainView.center.x = self.mainViewOriginalCenter.x + 280
        }) { (Bool) -> Void in
            self.sidebarShown = true
            self.mainView.addGestureRecognizer(self.mainViewPanGesture)
        }

        
    }
    
    func hideSidebar() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.mainView.center.x = self.mainViewOriginalCenter.x
        }) { (Bool) -> Void in
            self.sidebarShown = false
            self.mainView.removeGestureRecognizer(self.mainViewPanGesture)
        }
  
    }

    
}

