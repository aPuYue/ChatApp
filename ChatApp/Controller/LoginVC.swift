//
//  ViewController.swift
//  ChatApp
//
//  Created by puyue on 2018/6/6.
//  Copyright © 2018年 puyue. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class LoginVC: UIViewController { //class的继承
    
    @IBOutlet weak var emailField : UITextField! //首页email声明
    
    @IBOutlet weak var passwordField : UITextField! //首页pw声明

    var userUid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            
            performSegue(withIdentifier: "toMessages", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSignUp" {
            
            if let destination = segue.destination as? SignUpVC {
                
                if self.userUid != nil {
                    
                    destination.userUid = userUid
                }
                
                if self.emailField.text != nil {
                    
                    destination.emailField = emailField.text
                }
                
                if self.passwordField.text != nil {
                    
                    destination.passwordField = passwordField.text
                }
            }
        }
    }

    @IBAction func SignIn(_ sender: AnyObject) {  //登陆的函数
        
        if let email = emailField.text, let password = passwordField.text { //验证用户邮箱和密码
            //关键行,withEmail: email, password: password值发送给服务器,并且取得服务器的返回值completion的内容//此处的函数全是firebase服务器中定义过的,每个函数去查文档
            //Auth类的auth函数,对于返回值进行signIn函数 >> auth()的返回值就是Auth
            Auth.auth().signIn( withEmail: email, password: password, completion: {( authResult, error ) in
                //这里的代码是自己写的,用于得到completion值之后干些什么
                if error == nil {   //能不能登陆是看有没有出现error来判断的
                    self.userUid = authResult?.user.uid
                    
                    KeychainWrapper.standard.set(self.userUid, forKey: "uid")
                    
                    self.performSegue( withIdentifier: "toMessages", sender: nil)//toMessages是在主视图的signin跳转的地方定义的identity
                }
                else{
                    self.performSegue( withIdentifier: "toSignUp", sender: nil)  //toSignUp是在主视图的signin跳转的地方定义的identity
                }
            }
            
            )
        }
        
    }
    
    

}

