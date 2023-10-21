//
//  FeedVC.swift
//  14-FirebaseInstaClone
//
//  Created by Berke Ersiz on 26.08.2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import SDWebImage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var userEmail = [String]()
    var userComment = [String]()
    var likes = [Int]()
    var userImage = [String]()
    
    var documentId = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        getDataFromFirestore()
    }
    
    func getDataFromFirestore() {
        
        let firestoreDatabase = Firestore.firestore()
        //ilk once tarih ayari.FieldValue.serverTimestamp() boyle cektigimiz icin ayar lapmamiz lazim UploadVC. Eski versiyonlarda.
        firestoreDatabase.collection("Posts").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "errpr")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    //duplicate önlemek icin arrayleri temizliyoruz.
                    self.userImage.removeAll()
                    self.userEmail.removeAll()
                    self.userComment.removeAll()
                    self.likes.removeAll()
                    self.documentId.removeAll()
                    
                    for document in snapshot!.documents {
                        
                        let documentId = document.documentID
                        //print(documentId)
                        self.documentId.append(documentId)
                        
                        if let postedBy = document.get("postedBy") as? String {
                            self.userEmail.append(postedBy)
                            
                        }
                        if let postComment = document.get("postComment") as? String {
                            self.userComment.append(postComment)
                            
                        }
                        if let likes = document.get("likes") as? Int {
                            self.likes.append(likes)
                            
                        }
                        if let imageUrl = document.get("imageUrl") as? String {
                            self.userImage.append(imageUrl)
                            
                        }
                        
                        
                    }
                    self.tableView.reloadData()
                }
                
                
            }
        }
        
        
        
    }
    
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Kendi olusturdugum celli kullanmak icin.
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FeedCell
        
        cell.emailLabel.text = userEmail[indexPath.row]
        cell.likeLabel.text = String(likes[indexPath.row])
        cell.commentLabel.text = userComment[indexPath.row]
        cell.userImageView.sd_setImage(with: URL(string: self.userImage[indexPath.row]))
        cell.documentIdLabel.text = documentId[indexPath.row]
        return cell
    }
}
