//
//  Paypal.swift
//  JolicutREGLOG
//
//  Created by Guillaume FORESTIER on 21/04/16.
//  Copyright © 2016 Forestier Guillaume. All rights reserved.
//

import UIKit
import Foundation
import LocalAuthentication

class Paypal: UIViewController, PayPalPaymentDelegate {
    
    var ConfigPayPal = PayPalConfiguration()
    
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnectWithEnvironment(newEnvironment)
            }
        }
    }
    
    var acceptCreditCards: Bool = true {
        didSet {
            ConfigPayPal.acceptCreditCards = acceptCreditCards
        }
    }
    
    @IBAction func payerButton(sender: AnyObject) {
        authenticateUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConfigPayPal.acceptCreditCards = acceptCreditCards
        ConfigPayPal.merchantName = "Jolicut iOS"
        ConfigPayPal.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/va/webapps/mpp/ua/privacy-full")
        ConfigPayPal.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        ConfigPayPal.languageOrLocale = NSLocale.preferredLanguages()[0] as! String
        ConfigPayPal.payPalShippingAddressOption = .PayPal
        
        PayPalMobile.preconnectWithEnvironment(environment)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func payPalPaymentDidCancel(paymentViewController: PayPalPaymentViewController!) {
        print("Le paiement PayPal a été annulé")
        paymentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func payPalPaymentViewController(paymentViewController: PayPalPaymentViewController!, didCompletePayment completedPayment: PayPalPayment!) {
        print("Le paiement PayPal a été réussi")
        paymentViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            print("Voici le preuve de votre payment:\n\n\(completedPayment.confirmation)\n\nEnvoyez ceci au serveur pour confirmer votre payment")
        })
    }
    
    func authenticateUser()
        
    {
        
        let context = LAContext()
        
        var error = NSError?()
        
        let reasonSting = "Une authentification est nécessaire pour payer"
        
        
        
        print("1")
        
        
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)
            
        {
            print("1564648468")
            
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonSting, reply: { (success, policyError) -> Void in
                
                
                
                if success
                    
                {
                    
                    print("Authentification réussi")
                    
                }
                    
                else
                    
                {
                    
                    switch policyError?.code
                        
                    {
                        
                    case LAError.SystemCancel.rawValue?:
                        
                        print("Défaillance du système")
                        
                    case LAError.UserCancel.rawValue?:
                        
                        print("Transaction annulée par l'utilisateur")
                        
                    case LAError.UserFallback.rawValue?:
                        
                        print("L'utilisateur tape son mdp")
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock( {() -> Void in
                            
                            self.showPasswordAlert()
                            
                        })
                        
                    default:
                        
                        print("Echec de l'authentification")
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock( {() -> Void in
                            
                            self.showPasswordAlert()
                            
                        })
                        
                    }
                    
                }
                
            })
            
        }
            
        else
            
        {
            print("4894646")
            // Sinon on demande le  mot de passe
            print("1")
            print(error?.localizedDescription)
            
            //NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                self.showPasswordAlert()
                
            //})
            
        }
        
        
    }
    
    func bdd()
    {
        let testitem = PayPalItem(name : "Jolicut Item", withQuantity: 1, withPrice: NSDecimalNumber(string : "29.99"), withCurrency: "EUR", withSku: "Jolicut-0001")
        let items = [testitem]
        let totalitem = PayPalItem.totalPriceForItems(items)
        
        let livraison = NSDecimalNumber(string: "0.00")
        let taxe = NSDecimalNumber(string: "0.00")
        let detailsPayment = PayPalPaymentDetails(subtotal: totalitem, withShipping: livraison, withTax: taxe)
        
        let total = totalitem.decimalNumberByAdding(livraison).decimalNumberByAdding(taxe)
        
        let payment = PayPalPayment(amount: total, currencyCode: "EUR", shortDescription: "Jolicut", intent: .Sale)
        
        payment.items = items
        payment.paymentDetails = detailsPayment
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: ConfigPayPal, delegate: self)
            presentViewController(paymentViewController, animated: true, completion: nil)
        }
        else {
            print("Payment refusé : \(payment)")
        }
    }
    
    func showPasswordAlert()
        
    {
        
        let alertController = UIAlertController(title: "Touch ID Password", message: "PLease enter your password", preferredStyle: .Alert)
        
        
        let defaultAction = UIAlertAction(title: "OK", style: .Cancel) { (action) -> Void in
            
            
            
            if let textField = alertController.textFields?.first as UITextField?
                
            {
                
                if textField.text == "batman"
                    
                {
                    
                    //print("Réussi !")
                    self.bdd()
                    
                }
                    
                else
                    
                {
                    self.showPasswordAlert()
                    
                }
                
            }
            
        }
        
        alertController.addAction(defaultAction)
        
        
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
            textField.placeholder = "Password"
            
            textField.secureTextEntry = true
            
        }
        print(4646345)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
}


