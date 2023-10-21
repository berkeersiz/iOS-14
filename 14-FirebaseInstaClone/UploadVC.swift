//
//  UploadVC.swift
//  14-FirebaseInstaClone
//
//  Created by Berke Ersiz on 26.08.2023.
//

import UIKit
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class UploadVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentText: UITextField!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
            
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        //saveButton.isEnabled = true//Gorsel sectigimiz anda button ulasilabilir.
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadButton(_ sender: Any) {
        //Ilk once fotografi storage sonra commenti ve tarihi kaydedicez.
        let storage = Storage.storage()
        let storageReference = storage.reference()//bu referansi kullanarak hangi klasorle calisacagimizi nereye kaydedecegimizi belirtiyoruz.
        let mediaFolder = storageReference.child("media")//Storage icinde klasor olusturma.Klasor icinde klasor de olusturabilirim.
        
        if let  data = imageView.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            imageReference.putData(data) { metadata, error in
                if error != nil {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!")
                } else {
                    imageReference.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            
                            //***********DATABASE***********
                            
                            let firestoreDatabase = Firestore.firestore()
                            
                            var firestoreReference : DocumentReference? = nil//var yapmamizi xcode soyledi altta.
                            
                            let firestorePost = ["imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser!.email!, "postComment" : self.commentText.text!, "date" : FieldValue.serverTimestamp(), "likes" : 0] as [String : Any]
                            firestoreReference = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
                                if error != nil {
                                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error!")
                                } else {
                                    self.imageView.image = UIImage(named: "select")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0 //0-> feed 1-> upload 2-> settings in storyboard
                                    
                                }
                            })
                        }
                    }
                }
            }
        }
        
    }
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}
