//
//  SignupVC.swift
//  SwiftLoginScreen
//
//  Created by Forestier Guillaume on 20/04/16.
//  Copyright (c) 2015 Forestier Guillaume. All rights reserved.
//

import UIKit



class SignupVC: UIViewController {
    
    func validateNames(candidate: String) -> Bool {
        
        let namesRegex = "([A-Z][a-z-]{1,})$"
        let verification = NSPredicate(format: "SELF MATCHES %@", namesRegex).evaluateWithObject(candidate)
        return verification
    }
    
    
    
    func validateMdp(candidate: String) -> Bool {
        
        let mdpRegex = "([A-Za-z0-9]{6,20})"
        let verification = NSPredicate(format: "SELF MATCHES %@", mdpRegex).evaluateWithObject(candidate)
        return verification
    }
    
    
    
    func displayAlert(userMessage:String)
        
    {
        let alertView:UIAlertView = UIAlertView()
        alertView.title = "Sign Up Failed!"
        alertView.message = userMessage
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func displaySign(userMessage:String)
        
    {
        let alertView:UIAlertView = UIAlertView()
        alertView.title = "Sign Up Success!"
        alertView.message = userMessage
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    @IBOutlet var txtUsername : UITextField!
    @IBOutlet var txtPassword : UITextField!
    @IBOutlet var txtConfirmPassword : UITextField!
    
    @IBOutlet var txtNom: UITextField!
    
    @IBOutlet var txtPrenom: UITextField!

    @IBOutlet var txtPseudo: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func gotoLogin(sender : UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
        
    
    @IBAction func signupTapped(sender : UIButton) {
        let username:NSString = txtUsername.text!
        let password:NSString = txtPassword.text!
        let confirm_password:NSString = txtConfirmPassword.text!
        let nom:NSString = txtNom.text!
        let prenom:NSString = txtPrenom.text!
         let pseudo:NSString = txtPseudo.text!
        
        if ( (validateNames(nom as String) && validateNames(prenom as String)) == false )
        {
            displayAlert("Le nom ou le prenom n'est pas au bon format")
        }
        
        if ((validateMdp(password as String) && validateMdp(confirm_password as String)) == false)
        {
            displayAlert("Le mot de passe n'est pas au bon format")
        }
        
        if ( username.isEqualToString("") || password.isEqualToString("") || confirm_password.isEqualToString("") || nom.isEqualToString("") || prenom.isEqualToString("") || pseudo.isEqualToString("") ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Veuillez remplir les champs"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if ( !password.isEqual(confirm_password) ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Passwords doesn't Match"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            do {
                // Connexion BDD
                let post:NSString = "email=\(username)&password=\(password)&c_password=\(confirm_password)&nom=\(nom)&prenom=\(prenom)&pseudo=\(pseudo)"
                
                NSLog("PostData: %@",post);
                
                let url:NSURL = NSURL(string: "http://jolicut.16mb.com/jsonsignup.php")!
                
                let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
                
                let postLength:NSString = String( postData.length )
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                var reponseError: NSError?
                var response: NSURLResponse?
                
                var urlData: NSData?
                do {
                    urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                } catch let error as NSError {
                    reponseError = error
                    urlData = nil
                }
                
                if ( urlData != nil ) {
                    let res = response as! NSHTTPURLResponse!;
                    
                    NSLog("Response code: %ld", res.statusCode);
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            displaySign("Bienvenue")
                            NSLog("Sign Up SUCCESS");
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Unknown Error"
                            }
                            let alertView:UIAlertView = UIAlertView()
                            alertView.title = "Sign Up Failed!"
                            alertView.message = error_msg as String
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                            
                        }
                        
                    } else {
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = "Connection Failed"
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                }  else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign in Failed!"
                    alertView.message = "Connection Failure"
                    if let error = reponseError {
                        alertView.message = (error.localizedDescription)
                    }
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            } catch {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign Up Failed!"
                alertView.message = "Server Error!"
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
}
