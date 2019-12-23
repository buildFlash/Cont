//
//  ViewController.swift
//  Cont
//
//  Created by Aryan Sharma on 23/12/19.
//  Copyright © 2019 Aryan Sharma. All rights reserved.
//

import UIKit
import Contacts

class ContactListVC: UIViewController {
    
    var filteredContactsList = [CNContact]() {
        didSet {
            self.filteredContactsList.sort { (c1, c2) -> Bool in
                return c1.givenName < c2.givenName
            }
            sections.removeAll()
            for contact in self.filteredContactsList {
                let initial = getInitial(from: contact)
                if let _ = sections[initial] {
                    sections[initial]?.append(contact)
                } else {
                    sections[initial] = [contact]
                }
            }
            self.sectionTitles = [String](self.sections.keys)
            self.sectionTitles = self.sectionTitles.sorted(by: { $0 < $1 })
            self.tableView.reloadData()
        }
    }
    
    var contactList = [CNContact]()
    var isFiltering = false
    var sections = [String: [CNContact]]()
    var sectionTitles = [String]()
    let cellID = "cellID"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTableView()
        fetchContacts()
        title = "Contacts"
        overrideUserInterfaceStyle = .light
        self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        searchBar.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(syncContacts), name: .syncContacts, object: nil)
    }
        
    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        view.addSubview(tableView)
        let nib = UINib(nibName: "ContactCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
    }

    @objc private func syncContacts() {
        fetchContacts()
        if let text = searchBar.text, !text.isEmpty {
            searchBar(self.searchBar, textDidChange: text)
        }
    }
    
    func fetchContacts() {
        self.contactList.removeAll()
        let contactStore = CNContactStore()
        let keys = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                        CNContactPhoneNumbersKey,
                        CNContactEmailAddressesKey,
                        CNContactImageDataKey,
                        CNContactEmailAddressesKey,
                        CNContactBirthdayKey,
                        CNContactPostalAddressesKey
                ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                    (contact, stop) in
                self.contactList.append(contact)
                self.sortAndUpdateSections()
            }
        } catch let err {
            print("unable to fetch contacts \(err.localizedDescription)")
        }

    }
    
    private func sortAndUpdateSections() {
        self.contactList.sort { (c1, c2) -> Bool in
            return c1.givenName < c2.givenName
        }
        self.sections.removeAll()
        for contact in self.contactList {
            let initial = self.getInitial(from: contact)
            if let _ = self.sections[initial] {
                self.sections[initial]?.append(contact)
            } else {
                self.sections[initial] = [contact]
            }
        }
        self.sectionTitles = [String](self.sections.keys)
        self.sectionTitles = self.sectionTitles.sorted(by: { $0 < $1 })
        self.tableView.reloadData()
    }
    
    private func getInitial(from contact: CNContact) -> String {
        var initial = ""
        if contact.givenName.count > 0 {
            initial = "\(contact.givenName.first!)"
        } else if contact.familyName.count > 0 {
            initial = "\(contact.familyName.first!)"
        }
        return initial.uppercased()
    }

}

extension ContactListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = sectionTitles[section]
        if let val = sections[key] {
            return val.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? ContactCell {
            let key = sectionTitles[indexPath.section]
            if let contacts = sections[key] {
                cell.initWith(contact: contacts[indexPath.row])
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let key = sectionTitles[indexPath.section]
        if let contacts = sections[key] {
            if let contactDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContactDetailVC") as? ContactDetailVC {
                contactDetailVC.initWith(contact: contacts[indexPath.row])
                self.navigationController?.pushViewController(contactDetailVC, animated: true)
            }
            
        }

    }

}

extension ContactListVC: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.sortAndUpdateSections()
        self.tableView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchText.isEmpty {
            let arr = searchText.components(separatedBy: .whitespaces)
            self.filteredContactsList = self.contactList.filter {
                if arr.count == 1 {
                   return $0.givenName.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive ]) != nil ||
                    $0.familyName.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive ]) != nil
                } else {
                    return ($0.givenName.range(of: arr[0], options: [.caseInsensitive, .diacriticInsensitive ]) != nil &&
                    $0.familyName.range(of: arr[1], options: [.caseInsensitive, .diacriticInsensitive ]) != nil) ||
                    ($0.givenName.range(of: arr[1], options: [.caseInsensitive, .diacriticInsensitive ]) != nil &&
                    $0.familyName.range(of: arr[0], options: [.caseInsensitive, .diacriticInsensitive ]) != nil)

                }
            }
        } else {
            self.sortAndUpdateSections()
        }
        self.tableView.reloadData()
    }
}
