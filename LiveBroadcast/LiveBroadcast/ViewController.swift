//
//  ViewController.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 05/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileLabel: UILabel!
    @IBOutlet var notifyButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    
    let datePickerContainer = UIView()
    var scheduledDate = Date()
    
    var hasMicrophonePermission = false
    var hasCameraPermission = false
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM dd, hh:mm a"
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermissions()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        updateTableViewHeight()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func notifyButtonPressed(_ sender: UIButton) {
       
        showDatePicker()
        //Delegate.sendNotification()
    }
    
    @IBAction func viewLiveButtonPressed(_ sender: UIButton) {
        let recordingVC = self.storyboard?.instantiateViewController(withIdentifier: "recordingVC") as! RecordingViewController
        self.present(recordingVC, animated: true, completion: nil)
    }

    @IBAction func liveButtonPressed(_ sender: UIButton) {
       startLiveBroadcast()
    }
    
    func startLiveBroadcast() {
        guard hasMicrophonePermission else {
            requestMicrophonePermission { [unowned self] in
                self.startLiveBroadcast()
            }
            return
        }
        
        guard hasCameraPermission else {
            requestCameraPermission { [unowned self] in
                self.startLiveBroadcast()
            }
            return
        }
        
        let liveBroadCastVC = self.storyboard?.instantiateViewController(withIdentifier: "liveBroadcastVC") as! LiveBroadcastViewController
        self.present(liveBroadCastVC, animated: true, completion: nil)
    }
    
    func showDatePicker() {
        
        guard datePickerContainer.superview == nil else {
            return
        }
        
        let toolBar = UIToolbar(frame: .zero)
        toolBar.barStyle = .default
        toolBar.isUserInteractionEnabled = true
        
        let cancel = UIBarButtonItem(title: "Cancel", style:.plain, target: self, action: #selector(cancelClicked))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked))
        toolBar.setItems([cancel,space,done], animated: false)
        
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer.addSubview(toolBar)
        
        NSLayoutConstraint.activate([
            toolBar.leftAnchor.constraint(equalTo: datePickerContainer.leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: datePickerContainer.rightAnchor),
            toolBar.topAnchor.constraint(equalTo: datePickerContainer.topAnchor),
            toolBar.heightAnchor.constraint(equalToConstant: 44)
            ])
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 30
        datePicker.minimumDate = Date().addingTimeInterval(1800)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePickerContainer.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.leftAnchor.constraint(equalTo: datePickerContainer.leftAnchor),
            datePicker.rightAnchor.constraint(equalTo: datePickerContainer.rightAnchor),
            datePicker.bottomAnchor.constraint(equalTo: datePickerContainer.bottomAnchor),
            datePicker.topAnchor.constraint(equalTo: toolBar.bottomAnchor)
            ])
        
        
        datePickerContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(datePickerContainer)
        
        NSLayoutConstraint.activate([
            datePickerContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            datePickerContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            datePickerContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            datePickerContainer.heightAnchor.constraint(equalToConstant: 300)
            ])
        
    }
    
    @objc func cancelClicked() {
        datePickerContainer.removeFromSuperview()
    }
    
    @objc func doneClicked() {
        datePickerContainer.subviews.forEach { $0.removeFromSuperview() }
        datePickerContainer.removeFromSuperview()
        let event = ScheduledEvent(date: scheduledDate)
        EventManager.shared.addEvent(event)
        tableView.reloadData()
        updateTableViewHeight()
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        scheduledDate = sender.date
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EventManager.shared.allEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        let event = EventManager.shared.allEvents[indexPath.row]
        cell.dateLabel.text = dateFormatter.string(from: event.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
    
    func updateTableViewHeight() {
        let numRows = EventManager.shared.allEvents.count
        tableViewHeightConstraint.constant = CGFloat(numRows * 30)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ViewController {
    
    func checkPermissions() {
        let microphoneStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch microphoneStatus {
        case .authorized:
            hasMicrophonePermission = true
        default:
            hasMicrophonePermission = false
        }
        
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraStatus {
        case .authorized:
            hasCameraPermission = true
        default:
            hasCameraPermission = false
        }
    }
    
    func requestMicrophonePermission(_ completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { [unowned self](success) in
            self.hasMicrophonePermission = success
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func requestCameraPermission(_ completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self](success) in
            self.hasCameraPermission = success
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
}
