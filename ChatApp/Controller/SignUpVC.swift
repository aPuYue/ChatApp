//
//  SignUpVC.swift
//  ChatApp
//
//  Created by puyue on 2018/6/6.
//  Copyright © 2018年 puyue. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper


class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var userImagePicker: UIImageView!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    var userUid: String!
    
    var emailField: String!
    
    var passwordField: String!
    
    var imagePicker: UIImagePickerController!
    
    var imageSelected = false
    
    var username: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            
            performSegue(withIdentifier: "toMessages", sender: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            userImagePicker.image = image
            
            imageSelected = true
            
        } else {
            
            print("image wasnt selected")
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func setUser(img: String) {
        
        let userData = [
            "username": username!,
            "userImg": img
        ]
        
        KeychainWrapper.standard.set(userUid, forKey: "uid")
        
        let location = Database.database().reference().child("users").child(userUid)
        
        location.setValue(userData)
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImg() {
        
        if usernameField.text == nil {
            
            signUpBtn.isEnabled = false
            
        } else {
            
            username = usernameField.text
            
            signUpBtn.isEnabled = true
        }
        
        guard let img = userImagePicker.image, imageSelected == true else {
            
            print("image needs to be selected")
            
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            
            let metadata = StorageMetadata()
            
            metadata.contentType = "image/jpeg"
            
            let storageRef = Storage.storage().reference().child(imgUid)
            
            storageRef.putData(imgData, metadata: metadata) { (metadata: StorageMetadata?, error) in //函数参数是元祖的时候,第一个参数不需要写key
            //Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata, completion: { (StorageMetadata, error) in  //最后边的一个参数可以不写key,拿出来
                if error != nil {
                    
                    print("did not upload img")
                } else {
                    
                    print("uploaded")
                    
                    storageRef.downloadURL(completion: {( downloadURL , error) in
                        //因为版本改变了,本来是得到值然后赋值给downloadURL,现在不需要了,直接执行这一行,从括号里面得到downloadURL
                    
                        if let url = downloadURL {
                            
                            self.setUser(img: url.absoluteString)
                        }
                    }
                    )
                }
            }
        }
    }
    
    @IBAction func createAccount (_ sender: AnyObject) {
        
        Auth.auth().createUser(withEmail: emailField, password: passwordField, completion: { (authResult, error) in
            
            if error != nil {
                
                print("Cant create user")
            } else {
                
                if let user = authResult?.user {
                    
                    self.userUid = user.uid
                }
            }
            
            self.uploadImg()
        })
    }
    
    @IBAction func selectedImgPicker (_ sender: AnyObject) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel (_ sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    

    

}
