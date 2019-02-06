//
//  ViewController.swift
//  LiveBroadcast
//
//  Created by Alok Jha on 05/02/19.
//  Copyright © 2019 Alok Jha. All rights reserved.
//

import UIKit
import AVFoundation

class ProfileViewController: UIViewController {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var profileLabel: UILabel!
    @IBOutlet var scheduleButton: UIButton!
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var scheduledTableView: UITableView!
    @IBOutlet var scheduledTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var ongoingTableView: UITableView!
    @IBOutlet var ongoingTableViewHeightConstraint: NSLayoutConstraint!
    
    let currentUserType = User.shared.userType
    let datePickerContainer = UIView()
    var scheduledDate = Date()
    
    var hasMicrophonePermission = false
    var hasCameraPermission = false
    let dateFormatter = DateFormatter.appDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 3.0
        
        switch currentUserType {
        case .arist:
            profileLabel.text = artistName
            Delegate.unsubscribe(from: artistTopic)
        case .subscriber:
            profileLabel.text = subscriberName
            Delegate.subscribe(to: artistTopic)
        default:
            break
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(goLiveNotificationReceived(_:)), name: goLiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scheduleLiveNotificationReceived(_:)), name: scheduleLiveNotification, object: nil)
        
        checkPermissions()
        
        scheduledTableView.dataSource = self
        scheduledTableView.delegate = self
        scheduledTableView.reloadData()
        updateScheduledTableViewHeight()
        
        ongoingTableView.dataSource = self
        ongoingTableView.delegate = self
        ongoingTableView.reloadData()
        updateOngoingTableViewHeight()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func goLiveNotificationReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        
        if let stream = userInfo["stream"] as? String, let date = userInfo["date"] as? String {
            //live event
            let event = LiveEvent(date: date, hlsURL: stream)
            LiveEventManager.shared.addEvent(event)
            
            ongoingTableView.reloadData()
            updateOngoingTableViewHeight()
        }
    }
    
    @objc func scheduleLiveNotificationReceived(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo else {
            return
        }
        
        if let date = userInfo["date"] as? String {
            let event = ScheduledEvent(date: date)
            ScheduledEventManager.shared.addEvent(event)
            
            scheduledTableView.reloadData()
            updateScheduledTableViewHeight()
        }
    }
    
    @IBAction func scheduleButtonPressed(_ sender: UIButton) {
        showDatePicker()
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        User.shared.logOut()
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        Delegate.unsubscribe(from: artistTopic)
        Delegate.window?.rootViewController = loginVC
        LiveEventManager.shared.removeAllEvents()
        ScheduledEventManager.shared.removeAllEvents()
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
        
        DispatchQueue.main.async {
            let liveBroadCastVC = self.storyboard?.instantiateViewController(withIdentifier: "liveBroadcastVC") as! LiveBroadcastViewController
            self.present(liveBroadCastVC, animated: true, completion: nil)
        }
        
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
        
        let date = Date()
        let dateStr = dateFormatter.string(from: date)
        
        let event = ScheduledEvent(date: dateStr)
        ScheduledEventManager.shared.addEvent(event)
        scheduledTableView.reloadData()
        updateScheduledTableViewHeight()
        
        let payload = createScheduleEventNotificationPayload(withEvent: event, topic: artistTopic)
        Delegate.sendNotification(with: payload)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        scheduledDate = sender.date
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case ongoingTableView:
            return LiveEventManager.shared.allEvents.count
        case scheduledTableView:
            return ScheduledEventManager.shared.allEvents.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell
        
        switch tableView {
        case ongoingTableView:
            let event = LiveEventManager.shared.allEvents[indexPath.row]
            cell.dateLabel.text = event.date
        case scheduledTableView:
            let event = ScheduledEventManager.shared.allEvents[indexPath.row]
            cell.dateLabel.text = event.date
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case ongoingTableView:
            let event = LiveEventManager.shared.allEvents[indexPath.row]
            let recordingVC = self.storyboard?.instantiateViewController(withIdentifier: "recordingVC") as! RecordingViewController
            recordingVC.liveEvent = event
            self.present(recordingVC, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func updateScheduledTableViewHeight() {
        let numRows = ScheduledEventManager.shared.allEvents.count
        scheduledTableViewHeightConstraint.constant = CGFloat(numRows * 30)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateOngoingTableViewHeight() {
        let numRows = LiveEventManager.shared.allEvents.count
        ongoingTableViewHeightConstraint.constant = CGFloat(numRows * 30)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ProfileViewController {
    
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
