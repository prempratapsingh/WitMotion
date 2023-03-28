//
//  HistoryRecordViewController.swift
//  WitMotion
//
//  Created by Prem Pratap Singh on 24/03/23.
//

import UIKit

class HistoryRecordViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - UI controls
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Public properties
    
    var filePath: String!
    var lists: [String] = []
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString("historyRecord",  comment: "")
        self.getFilesList()
    }
    
    // MARK: - Private methods
    
    private func getFilesList() {
        guard let lists = DataFileManager.listFilesInDirectoryAtPath(self.filePath, deep: false) else { return }
        self.lists = lists
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !self.lists.isEmpty else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCellID", for: indexPath)
        cell.backgroundColor = UIColorFromRGB(0x131313)
        let fileName = self.lists[indexPath.row]
        cell.textLabel?.text = fileName
        cell.textLabel?.textColor = UIColor.white
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileName = self.lists[indexPath.row]
        if self.filePath == DataFileManager.fileRootPath() {
            let historyRecordVC = HistoryRecordViewController()
            historyRecordVC.filePath = self.filePath.appending(fileName)
            self.navigationController?.pushViewController(historyRecordVC, animated: true)
        } else {
            let recordFileName = self.filePath.appending(fileName)
            DataFileManager.shareActivityVC(self, recordFileName: recordFileName)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return NSLocalizedString("Delete",  comment: "")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileName = self.lists[indexPath.row]
            let recordFileName = self.filePath.appending(fileName)
            if DataFileManager.removeItemAtPath(recordFileName) {
                self.lists.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
