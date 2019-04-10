//
//  ChatViewController.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 14/9/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import UIKit
import PKHUD



class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var heigntPhoto: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var heightTextView: NSLayoutConstraint!
    @IBOutlet weak var txtHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var buttonGallery: UIButton!
    @IBOutlet weak var buttonCamera: UIButton!
    @IBOutlet weak var heightButtonImage: NSLayoutConstraint!
    
    
    var selectedImage: UIImage?
    var userID : Int?
    var driverID: Int?
    var shipment: Shipment?
    var existChatConver = false
    var idChat : Int?
    var arrayMessages = [MessageModel]()
    // Presenter
    fileprivate let presenter = ChatPresenter(chatService: ChatServices())
    
    //notification
    static let ChatRefreshNotification = "ChatRefreshNotification"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        userID = Global_UserSesion?.id
        driverID = shipment?.driver?.id
        self.navigationItem.title = shipment?.driver?.name
        tableView.delegate = self
        tableView.register(IncomingMessagesCell.nib , forCellReuseIdentifier: "IncomingMessagesCell")
        tableView.register(SentMessagesCell.nib , forCellReuseIdentifier: "SentMessagesCell")
        textField.text = "WRITE HERE".localized
        textField.delegate = self
        presenter.attachView(view: self)
        
        
        //creamos temporalmente unos mensajes enviados por el cliente
//        let object = customObject(username: "ALGUIEN RANDOM", sms: "Hola Estoy atrapado en este lugar", img: #imageLiteral(resourceName: "bg-wizard"), containImg: false)
//        let object2 = customObject(username: "ALGUIEN RANDOM", sms: "Tardare un poco en llegar", img: #imageLiteral(resourceName: "bg-splash-dia"), containImg: true)

        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.receivedNotification(_:)), name: NSNotification.Name(rawValue: "ChatRefreshNotification"), object: nil)
        checkExistChat()
        */
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userID = Global_UserSesion?.id
        driverID = shipment?.driver?.id
        self.navigationItem.title = shipment?.driver?.name
        tableView.delegate = self
        tableView.register(IncomingMessagesCell.nib , forCellReuseIdentifier: "IncomingMessagesCell")
        tableView.register(SentMessagesCell.nib , forCellReuseIdentifier: "SentMessagesCell")
        textField.text = "WRITE HERE".localized
        textField.delegate = self
        presenter.attachView(view: self)
        
        
        //creamos temporalmente unos mensajes enviados por el cliente
        //        let object = customObject(username: "ALGUIEN RANDOM", sms: "Hola Estoy atrapado en este lugar", img: #imageLiteral(resourceName: "bg-wizard"), containImg: false)
        //        let object2 = customObject(username: "ALGUIEN RANDOM", sms: "Tardare un poco en llegar", img: #imageLiteral(resourceName: "bg-splash-dia"), containImg: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.receivedNotification(_:)), name: NSNotification.Name(rawValue: "ChatRefreshNotification"), object: nil)
        checkExistChat()
        isNewMessage = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkExistChat(){
        guard let shipmentID = shipment?.id else {
            return
        }
        self.existChat(shipment_id: String(shipmentID))
    }

    @IBAction func sendComment(_ sender: Any) {
        
        if textField.text != "WRITE HERE".localized && textField.text.count != 0{
            self.view.endEditing(true)
            
            if existChatConver{
                print("No hacemos nada \(existChatConver)")
                if let idChat = arrayMessages[0].conversation_id{
                    
                    sendMessage(conversation_id: idChat, message: self.textField.text)
                    textField.text = "WRITE HERE".localized
                    textViewDidChange(textField)
                }
            }else{
                if let message = self.textField.text{
                    createChatConver(message: message)
                    textField.text = "WRITE HERE".localized
                    textViewDidChange(textField)
                }

            }

        }
    }
    
    func reloadTableView(){
        tableView.reloadData()
        isNewMessage = false // probando esto
        if arrayMessages.count > 0{
          tableView.scrollToBottom()
        }        
    }
    
    func createChatConver(message: String){

        guard let shipmentID = shipment?.id else {
            return            
        }
        self.createChatRoom(shipment_id: String(shipmentID), message: message)
    }
    
    func deleteImage(){
        selectedImage = nil
        photo.image = nil
        self.heigntPhoto.constant = 0
        self.heightButtonImage.constant = 0
    }
    
    @IBAction func removeImage(_ sender: UIButton) {
        deleteImage()
    }
    
    @IBAction func addPhoto() {
    if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func addImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate =  self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        self.buttonCamera.setImage(nil, for: .normal)
        self.buttonGallery.setImage(nil, for: .normal)
        self.buttonCamera.isHidden = true
        self.buttonGallery.isHidden = true
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .transitionFlipFromBottom, animations:{
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: Notification){
        self.buttonCamera.setImage(#imageLiteral(resourceName: "foto_muro"), for: .normal)
        self.buttonGallery.setImage(#imageLiteral(resourceName: "img2"), for: .normal)
        self.buttonCamera.isHidden = false
        self.buttonGallery.isHidden = false
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: .transitionFlipFromBottom ,
            animations:{
                self.view.layoutIfNeeded()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMessagesCell", for: indexPath) as! SentMessagesCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "IncomingMessagesCell", for: indexPath) as! IncomingMessagesCell
        
        if arrayMessages[indexPath.row].user_id == userID {
            if let sms = arrayMessages[indexPath.row].body{
                cell.updateCommentCell(sms: sms, img: #imageLiteral(resourceName: "img2"), sendImage: false)
            }
            return cell
        }else{
            if let sms = arrayMessages[indexPath.row].body{
                 cell2.updateCommentCell(userName: "", sms: sms, img: #imageLiteral(resourceName: "img2"), sendImage: false)
            }
            return cell2
        }
        
    }

}

extension ChatViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info [UIImagePickerControllerEditedImage] as? UIImage  {
            //editingMode = true
            selectedImage = editedImage
            photo.image = selectedImage
            self.heigntPhoto.constant = 256
            self.heightButtonImage.constant = 30
        }
        picker.dismiss(animated: true)
    }
}

extension ChatViewController : UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(textView.text == "WRITE HERE".localized){
            textView.text = ""
            textViewDidChange(textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == ""){
            textView.text = "WRITE HERE".localized
            textViewDidChange(textView)
        }
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textField.isScrollEnabled = textField.contentSize.height < self.txtHeightConstraint.constant
        
        return true
    }
 
    
    func numberOfLines(textView: UITextView) -> Int {
        let layoutManager = textView.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0
        
        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
        print("width ---> \(textView.frame.size.width)")
        print("height ---> \(textView.frame.size.height)")
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let stimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach{
            (constraint) in
            
            if constraint.firstAttribute  == .height {
                constraint.constant = stimatedSize.height
            }else{
                return
            }
        }
    }
    
}

extension UITableView {
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}


extension ChatViewController: ChatProtocol{
    
    func existChat(shipment_id: String) {
        presenter.consultExistChat(shipment_id: shipment_id)
    }
    
    func sendMessage(conversation_id: Int, message: String) {
        presenter.send(conversation_id: conversation_id, message: message)
    }
    
    func respuestaSendMessage(status: Bool) {
        if status{
            self.checkExistChat()
        }else{
            print("algo paso")
        }
    }
    
    func getMessages(arrayMessages: [MessageModel]) {
        self.existChatConver = true
        self.arrayMessages = arrayMessages
        self.reloadTableView()
    }
    
    func didError(message: String) {
        self.arrayMessages.removeAll()
        self.reloadTableView()
    }
    
    func createChatRoom(shipment_id: String, message: String) {
        presenter.createChat(shipment_id: shipment_id, message: message)
    }
    
    func respuestaExistChat(respuesta: Bool, idChat: Int ,arrayMessages: [MessageModel]?) {
        switch respuesta {
        case true:
           self.existChatConver = respuesta
           if let arrayMessages = arrayMessages{
            self.arrayMessages = arrayMessages
           }
           self.idChat = idChat
           self.reloadTableView()
            break
        case false:
            self.idChat = nil
            self.existChatConver = respuesta
            break
        }
    }
    
    func showConvertation(conversationsID: String) {
        arrayMessages.removeAll()
        self.reloadTableView()
        self.presenter.getConversation(conversationsID: conversationsID)
    }
    
    
    @objc func  receivedNotification(_ notification: Notification) {
        
        DispatchQueue.main.async {
            guard let userInfo = notification.userInfo, let transmitter_id = userInfo["transmitter_id"] as? String, let conversation_id = userInfo["conversation_id"] as? String else{
                print("--> ERROR File: ChatViewController in LINE 356 (receivedNotification) : No userInfo found in notification")
                return
            }
            print("Transmitter_id --> \(transmitter_id)")
            self.showConvertation(conversationsID: conversation_id)
            
            
        }
        
    }
    
}

