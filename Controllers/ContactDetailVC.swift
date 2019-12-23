//
//  ContactDetailVC.swift
//  Cont
//
//  Created by Aryan Sharma on 23/12/19.
//  Copyright © 2019 Aryan Sharma. All rights reserved.
//

import UIKit
import Contacts
import MessageUI
import CoreLocation

enum ContactDetailType: Hashable {
    case phoneNumber
    case address
    case email
    case birthday
}

class ContactDetailVC: UIViewController {
    
    //MARK: - Variables
     var contact: CNContact! {
        didSet {
            sections[.phoneNumber] = contact.phoneNumbers.count
            sections[.email] = contact.emailAddresses.count
            sections[.address] = contact.postalAddresses.count
            sections[.birthday] = contact.birthday == nil ? 0 : 1
        }
    }
    private var cellID = "cellID"
    //MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var sections = [
        ContactDetailType.address : 0,
        ContactDetailType.email : 0,
        ContactDetailType.phoneNumber : 0,
        ContactDetailType.birthday : 0
    ]
    
    
    //MARK: - LifeCycle Methods
    
    func initWith(contact: CNContact) {
        self.contact = contact
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        overrideUserInterfaceStyle = .light
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        imageView.layer.cornerRadius = imageView.frame.height / 2
        self.nameLabel.text = contact.givenName + " " + contact.familyName
        if let data = contact.imageData {
            imageView.image = UIImage(data: data)
        } else if let image = UIImage.getImage(from: contact.givenName, lastName: contact.familyName, fontSize: 25) {
            imageView.image = image
        }
        if contact.phoneNumbers.count == 0 {
            self.callBtn.isEnabled = false
            self.callBtn.alpha = 0.5
            self.messageBtn.isEnabled = false
            self.messageBtn.alpha = 0.5
        }
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - IBActions
    
    @IBAction func messageBtnPressed(_ sender: Any) {
        if contact.phoneNumbers.count == 1 {
            sendMessage(phoneNumber: contact.phoneNumbers.first!.value)
        } else if contact.phoneNumbers.count > 1 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for number in contact.phoneNumbers {
                alert.addAction(UIAlertAction.init(title: number.value.stringValue, style: .default, handler: { [unowned self] (action) in
                    self.sendMessage(phoneNumber: number.value)
                }))
            }
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func callBtnPressed(_ sender: Any) {
        if contact.phoneNumbers.count == 1 {
            call(phoneNumber: contact.phoneNumbers.first!.value)
        } else if contact.phoneNumbers.count > 1 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for number in contact.phoneNumbers {
                alert.addAction(UIAlertAction.init(title: number.value.stringValue, style: .default, handler: { [unowned self] (action) in
                    self.call(phoneNumber: number.value)
                }))
            }
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func call(phoneNumber: CNPhoneNumber) {
        if let url = URL(string: "tel://\(phoneNumber.stringValue)".replacingOccurrences(of: " ", with: "")),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func sendMessage(phoneNumber: CNPhoneNumber) {
        if MFMessageComposeViewController.canSendText() {

            let controller = MFMessageComposeViewController()
            
            controller.messageComposeDelegate = self
            controller.recipients = [phoneNumber.stringValue]
            self.present(controller, animated: true, completion: nil)

        }
    }

    
}

extension ContactDetailVC : MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }

    
}

extension ContactDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sections[.phoneNumber] ?? 0
        } else if section == 1 {
            return sections[.email] ?? 0
        } else if section == 2 {
            return sections[.address] ?? 0
        } else if section == 3 {
            return sections[.birthday] ?? 0
        }
        return 0
    }
    
    func updateCell(with cell: UITableViewCell, title: String, subtitle: String) {
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = subtitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        
        cell.textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 18)
        cell.textLabel?.textColor = .darkText
        cell.detailTextLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        cell.detailTextLabel?.textColor = .systemBlue
        cell.detailTextLabel?.numberOfLines = 0

        if indexPath.section == 0 {
            let phoneNumber = contact.phoneNumbers[indexPath.row]
            updateCell(with: cell,
                       title: CNLabeledValue<NSString>.localizedString(forLabel: phoneNumber.label ?? ""),
                       subtitle: phoneNumber.value.stringValue)
        } else if indexPath.section == 1 {
            let email = contact.emailAddresses[indexPath.row]

            updateCell(with: cell,
                       title: CNLabeledValue<NSString>.localizedString(forLabel: email.label ?? ""),
                       subtitle: String(email.value))
        } else if indexPath.section == 2 {
            let address = contact.postalAddresses[indexPath.row]
            updateCell(with: cell,
                       title: CNLabeledValue<NSString>.localizedString(forLabel: address.label ?? ""),
                       subtitle: CNPostalAddressFormatter.string(from:address.value, style: .mailingAddress).replacingOccurrences(of: "\n", with: ", "))
        } else if indexPath.section == 3 {
            if let birthdayDateComponents = contact.birthday,
                let date = Calendar.current.date(from: birthdayDateComponents) {
                cell.textLabel?.text = "Birthday"
                
                let formatter = DateFormatter()
                formatter.dateStyle = .full
                updateCell(with: cell,
                           title: "Birthday",
                           subtitle: formatter.string(from: date))
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let phoneNumber = contact.phoneNumbers[indexPath.row]
            call(phoneNumber: phoneNumber.value)
        } else if indexPath.section == 1 {
            let email = contact.emailAddresses[indexPath.row]
            if let url = URL(string: "mailto:\(email.value)") {
                UIApplication.shared.open(url)
            }

        } else if indexPath.section == 2 {
            let address = contact.postalAddresses[indexPath.row]
            print(address)
            let str = CNPostalAddressFormatter.string(from:address.value, style: .mailingAddress).replacingOccurrences(of: "\n", with: ", ")
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(str) { (placemarksOptional, error) -> Void in
              if let placemarks = placemarksOptional, let location = placemarks.first?.location {
                  let query = "?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
                  let path = "http://maps.apple.com/" + query
                  if let url = URL(string: path) {
                    UIApplication.shared.open(url)
                  }
                }
            }
        }
    }
}
