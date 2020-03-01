//
//  RecordingsViewController.swift
//  iTranslateSample01
//
//  Created by Tarun Mukesh Kinger on 29/02/20.
//  Copyright © 2020 iTranslate. All rights reserved.
//

import UIKit

class RecordingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var recordingsTableView: UITableView?
    var recordingsListModel = RecordingsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataSource()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        animateTable()
    }
    
    func animateTable() {
        recordingsTableView?.reloadData()
            
        let cells = recordingsTableView?.visibleCells
        let tableHeight: CGFloat = recordingsTableView?.bounds.size.height ?? 0
            
        for i in cells ?? [] {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
            
        var index = 0
            
        for a in cells ?? [] {
            let cell: UITableViewCell = a as UITableViewCell
             
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .allowAnimatedContent, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
                
            index += 1
        }
    }
    
    func loadDataSource() {
        self.recordingsListModel.createRecordingsViewModel()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordingsListModel.recordingsViewModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingsTableViewCell", for: indexPath) as? RecordingsTableViewCell, let recordsModel = self.recordingsListModel.recordingsViewModels?[indexPath.row] {
            // Configure the cell...
            cell.setRecordingData(recordsModel)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RecordingsTableViewCell, let recordsModel = self.recordingsListModel.recordingsViewModels?[indexPath.row] {
            cell.startProgress(recordsModel)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                            section: Int) -> String? {
        return "RECENTLY USED"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

            let action =  UIContextualAction(style: .normal, title: nil, handler: { (action,view,completionHandler ) in
                //do stuff
                let recordingModel = self.recordingsListModel.recordingsViewModels?[indexPath.row]
                if self.recordingsListModel.removeRecording(recordingModel) {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                }
                completionHandler(true)
            })
        action.image = UIImage(named: "DeleteButton")
        action.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action])

        return configuration
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
