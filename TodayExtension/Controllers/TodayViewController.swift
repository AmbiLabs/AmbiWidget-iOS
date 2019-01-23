//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Milan Sosef on 22/11/2018.
//  Copyright © 2018 tonglaicha. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    var deviceViewModels: [DeviceViewModel]?
	var currentDeviceId: String? {
		get {
			return UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.string(forKey: UserDefaultsKeys.currentDeviceId)
		}
		set(newValue) {
			UserDefaults(suiteName: UserDefaultsKeys.appGroupName)!.set(newValue, forKey: UserDefaultsKeys.currentDeviceId)
		}
	}
	
	enum Overlay {
		case AuthOverlay
		case NoDevicesOverlay
		case LoadingOverlay
		case NoInternetOverlay
		
		var viewController: UIViewController {
			switch self {
			case .AuthOverlay:
				return AuthViewController()
			case .NoDevicesOverlay:
				return NoDevicesViewController()
			case .NoInternetOverlay:
				return NoInternetViewController()
			case .LoadingOverlay:
				return LoadingViewController()
			}
		}
	}
    
    enum SwitchDirection {
        case left
        case right
    }
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var modeIcon: UIImageView!
    @IBOutlet weak var bitWarmButton: UIButton!
    @IBOutlet weak var bitColdButton: UIButton!
    @IBOutlet weak var comfortButton: UIButton!
    @IBOutlet weak var offButton: UIButton!
    @IBOutlet weak var buttonRow: UIStackView!
    @IBOutlet weak var mainView: UIStackView!
	@IBOutlet weak var iconHumidity: UIImageView!
	@IBOutlet weak var iconTemperature: UIImageView!
	@IBOutlet weak var buttonSwitchLeft: UIButton!
	@IBOutlet weak var buttonSwitchRight: UIButton!
    
    // Do any additional setup after loading the view from its nib.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		
		// Listener for no internet connect subview
		NotificationCenter.default.addObserver(self, selector: #selector(onReconnectButtonPressed(_:)), name: .onReconnectButtonPressed, object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        print("View will appear")
		
		// Set button image view
        buttonSwitchLeft.imageView!.contentMode = .scaleAspectFit
        buttonSwitchLeft.imageEdgeInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
        buttonSwitchRight.imageView!.contentMode = .scaleAspectFit
        buttonSwitchRight.imageEdgeInsets = UIEdgeInsets(top: -20, left: -20, bottom: -20, right: -20)
		
		// Set tint colors of icons, because storyboard has bug
		let darkGreyColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
		iconHumidity.tintColor = darkGreyColor
		iconTemperature.tintColor = darkGreyColor
		buttonSwitchLeft.tintColor = darkGreyColor
		buttonSwitchRight.tintColor = darkGreyColor
	}
	
	//
	// Called when the user changes the displayMode (show less/more button)
	//
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		
		func hideOverlayLabel(for overlay: Overlay, _ value: Bool) {
			
			for child in self.children {
				switch overlay {
				case .AuthOverlay:
					if child is AuthViewController { (child as! AuthViewController).authLabel.isHidden = value }
				case .NoInternetOverlay:
					if child is NoInternetViewController { (child as! NoInternetViewController).noInternetLabel.isHidden = value }
				default:
					break
				}
			}
		}
		
        if activeDisplayMode == .compact {
			// SubViews
			hideOverlayLabel(for: .AuthOverlay, true)
			hideOverlayLabel(for: .NoInternetOverlay, true)
			
			// MainView
            self.buttonRow.isHidden = true
            self.preferredContentSize = maxSize
        }
		else if activeDisplayMode == .expanded {
			// SubViews
			hideOverlayLabel(for: .AuthOverlay, false)
			hideOverlayLabel(for: .NoInternetOverlay, false)
			
			// MainView
            self.buttonRow.isHidden = false
            self.preferredContentSize = CGSize(width: maxSize.width, height: 220)
        }
    }
	
	//
	// Called when the widget needs to update according to iOS.
	//
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		updateWidget()
        completionHandler(NCUpdateResult.newData)
    }
	
	@objc func onReconnectButtonPressed(_ notification: Notification) {
		removeOverlay(.NoInternetOverlay)
		addOverlay(.LoadingOverlay)
		updateWidget()
	}
    
    //
    // Performs an update on the widget.
    //
	func updateWidget() {
        // If the refresh token does not exist, show authentication overlay with button to containing app.
        guard let _ = try? TokenManager.loadTokenFromUserDefaults(with: .RefreshToken) else {
			self.addOverlay(.AuthOverlay)
            return
        }
        
        self.updateMainView()
        self.updateLocalDeviceList()
    }
	
	//
	// Adds an overlay (child view) to the mainView.
	// This overlaps and hides the mainView.
	//
	func addOverlay(_ overlayType: Overlay) {
		mainView.isHidden = true
		let overlayViewController = overlayType.viewController
		overlayViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
		add(overlayViewController)
		
		// ## Hide or show elements based on available space
		// If compact
		if self.extensionContext!.widgetActiveDisplayMode == .compact {
			// Hide Auth Overlay's label (text)
			switch overlayType {
			case .AuthOverlay:
				(overlayViewController as! AuthViewController).authLabel.isHidden = true
			case .NoInternetOverlay:
				(overlayViewController as! NoInternetViewController).noInternetLabel.isHidden = true
			default:
				break
			}
		}
		// If expanded
		else {
			// Show Auth Overlay's label (text)
			switch overlayType {
			case .AuthOverlay:
				(overlayViewController as! AuthViewController).authLabel.isHidden = false
			case .NoInternetOverlay:
				(overlayViewController as! NoInternetViewController).noInternetLabel.isHidden = false
			default:
				break
			}
		}
	}
	
	//
	// Removes all child view 'loading view(Controller)' from the mainView.
	//
	func removeOverlay(_ overlay: Overlay) {
		
		for child in self.children {
			switch overlay {
			case .AuthOverlay:
				if child is AuthViewController { child.remove() }
			case .NoDevicesOverlay:
				if child is NoDevicesViewController { child.remove() }
			case .NoInternetOverlay:
				if child is NoInternetViewController { child.remove() }
			case .LoadingOverlay:
				if child is LoadingViewController { child.remove() }
			}
		}
		
		// Show mainView again if no childs (overlays) exist
		if children.count < 1 {
			mainView.isHidden = false
		}
	}
	
	//
	// Updates the main interface view with the relative data from
	// the local device list.
	//
    public func updateMainView() {
		print("updateWidgetViews() # children:\(children)")
        
        // Get deviceList from local storage. If not existing, stop.
        guard let localDeviceList = try? DeviceManager.Local.getDeviceList() else {
            return
        }
        
        // Update deviceViewModels from local storage.
        self.deviceViewModels = localDeviceList.map({ return
            DeviceViewModel(device: $0)})
		
		// If no current device view model is set AND no default could be set, stop.
		guard let currentDeviceViewModel = getCurrentDeviceViewModel() else {
			return
		}
        
        self.deviceNameLabel.text = currentDeviceViewModel.deviceTitleText
        self.locationNameLabel.text = currentDeviceViewModel.locationNameText
        self.temperatureLabel.text = currentDeviceViewModel.temperatureLabel
        self.humidityLabel.text = currentDeviceViewModel.humidityLabel
        self.modeIcon.image = currentDeviceViewModel.modeIcon
        
        print("Updated view with local device status.")
    }
	
	
	func noInternetErrorHandler(_ error: Error) -> Bool {
		// Check if no internet connection error
		if let err = error as? URLError, err.code  == URLError.Code.notConnectedToInternet {
			// Show no devices overlay
			self.addOverlay(.NoInternetOverlay)
			return true
		}
		return false
	}
	
	//
	// Updates the local device list with new data from API
	//
    func updateLocalDeviceList() {
        print("Updating local device list")
		
		// If no existing data exist, show loading view
		if (try? DeviceManager.Local.getDeviceList()) == nil {
			self.addOverlay(.LoadingOverlay)
			print("added loadingOverlay # children:\(children)")
		}
        
        // Get new device data from the API
        DeviceManager.API.getDeviceList()
		.then { newDeviceList in
			DeviceManager.API.getDeviceStatus(for: newDeviceList)
		}.done { [weak self] updatedDeviceList in
			
			// Save deviceList to local storage
			try! DeviceManager.Local.saveDeviceList(deviceList: updatedDeviceList)
			
			// Update mainView to show the new data
			self?.updateMainView()
		}.catch { error in
			switch error {
			case DeviceManagerError.noDevicesForAccount:
				// Show no devices overlay
				self.addOverlay(.NoDevicesOverlay)
			default:
				print("Error: \(error)")
				// Check if no internet connection error
				let _ = self.noInternetErrorHandler(error)
			}
		}.finally {
			// Remove loading animation
			self.removeOverlay(.LoadingOverlay)
		}
    }
	
	//
	// Gets the current device view model based on the currentDeviceId
	// will look for the current device in [deviceViewModels]
	//
	func getCurrentDeviceViewModel() -> DeviceViewModel? {
		var deviceViewModel: DeviceViewModel?
		
		// If no deviceViewModels exist, return nil
		if deviceViewModels == nil { return nil }
		if deviceViewModels!.count < 1 { return nil }
		
		// Look for current device view model based on id
		for i in 0..<self.deviceViewModels!.count {
			if self.deviceViewModels![i].device.id == currentDeviceId {
				deviceViewModel = self.deviceViewModels![i]
			}
		}
		
		if deviceViewModel == nil {
			deviceViewModel = deviceViewModels![0]
			currentDeviceId = deviceViewModels![0].device.id
			print("currentDeviceViewModel not found, using default index 0")
		}
		
		return deviceViewModel
	}
	
	func getCurrentDeviceViewModelIndex() -> Int {
		var index: Int = 0
		for i in 0..<self.deviceViewModels!.count {
			if self.deviceViewModels![i].device.id == currentDeviceId {
				index = i
			}
		}
		return index
	}
	
	//
	// Updaes the currently shown/selected device with new data from API
	//
	func updateCurrentDevice() {
		print("Updating current device list")
		
		guard let currentDeviceViewModel = getCurrentDeviceViewModel() else {
			print("Could not update current device, currentDeviceViewModel not found")
			return
		}
		
		// Get new device data from the API
		DeviceManager.API.getDeviceStatus(for: currentDeviceViewModel.device)
		.done { newDeviceSatus in
			
			// Get current deviceList
			let deviceList = try! DeviceManager.Local.getDeviceList()
			
			// Update devicelist with new device status data
			var updatedDeviceList = deviceList
			for i in 0..<deviceList.count {
				if deviceList[i].id == currentDeviceViewModel.device.id {
					updatedDeviceList[i].status = newDeviceSatus
				}
			}
	
			// Save deviceList to local storage
			try! DeviceManager.Local.saveDeviceList(deviceList: updatedDeviceList)
	
			// Update widget views
			self.updateMainView()
		}.catch { error in
			print("Error: \(error)")
			let _ = self.noInternetErrorHandler(error)
		}
	}
	
	func changeModeIcon(to mode: SimpleMode) {
		let deviceList = try! DeviceManager.Local.getDeviceList()
		var updatedDeviceList = deviceList
		updatedDeviceList[getCurrentDeviceViewModelIndex()].simpleMode = mode
		try! DeviceManager.Local.saveDeviceList(deviceList: updatedDeviceList)
	}
	
    @IBAction func GiveComfortFeedback(_ sender: UIButton) {
        // Get the current device viewModel.
		guard let currentDevice = getCurrentDeviceViewModel()?.device else {
			print("Could not give comfort feedback, currentDeviceViewModel not found")
			return
		}
		
		// Determine feedback type based on the button tag / id that is pressed
        var comfortLevel: ComfortLevel?
        if sender.tag == 1 {
            // Show loading indicator.
            bitWarmButton.loadingIndicator(show: true)
            comfortLevel = .BitWarm
        } else if sender.tag == 2 {
            // Show loading indicator.
            bitColdButton.loadingIndicator(show: true)
            comfortLevel = .BitCold
        }
        
        // Send comfort feedback to the API.
        DeviceManager.API.giveComfortFeedback(for: currentDevice, with: comfortLevel!)
		.done { deviceOnline in
			print("Feedback given: \(comfortLevel!)")
			// Set mode icon
			deviceOnline ? self.changeModeIcon(to: .Comfort) : self.changeModeIcon(to: .Disconnected)
			self.updateMainView()
		}.catch { error in
			print("Error: \(error)")
			let _ = self.noInternetErrorHandler(error)
		}.finally {
			// Hide loading indicator.
			comfortLevel == .BitWarm ? self.bitWarmButton.loadingIndicator(show: false) : self.bitColdButton.loadingIndicator(show: false)
		}
    }
    
    @IBAction func switchToComfortMode(_ sender: UIButton) {
		print("func switchToConfortMode()")
		// Show loading indicator.
        self.comfortButton.loadingIndicator(show: true)
        
		guard let currentDevice = getCurrentDeviceViewModel()?.device else {
			print("Could not give comfort feedback, currentDeviceViewModel not found")
			return
		}
        
        // Send comfort mode instruction to the API.
        DeviceManager.API.comfortMode(for: currentDevice, with: SimpleMode.Comfort)
		.done { deviceOnline in
			print("The device has been set to comfort mode.")
			// Set mode icon
			deviceOnline ? self.changeModeIcon(to: .Comfort) : self.changeModeIcon(to: .Disconnected)
			self.updateMainView()
		}.catch { error in
			print("Error: \(error)")
			let _ = self.noInternetErrorHandler(error)
		}.finally {
			// Hide loading indicator.
			self.comfortButton.loadingIndicator(show: false)
		}
    }
    
    
    @IBAction func switchDeviceToOffMode(_ sender: UIButton) {
		// Show loading indicator.
        self.offButton.loadingIndicator(show: true)
        
		guard let currentDevice = getCurrentDeviceViewModel()?.device else {
			print("Could not give comfort feedback, currentDeviceViewModel not found")
			return
		}
        
        // Send power off instruction to the API.
        DeviceManager.API.powerOff(for: currentDevice)
		.done { deviceOnline in
			print("The device has been set to off mode.")
			// Set mode icon
			deviceOnline ? self.changeModeIcon(to: .Off) : self.changeModeIcon(to: .Disconnected)
			self.updateMainView()
		}.catch { error in
			print("Error: \(error)")
			// Check if no internet connection error
			let _ = self.noInternetErrorHandler(error)
			
			// API Bug: When 503 http error (service unavailable) it means the device is offline/unreachable
			if case HttpError.serviceUnavailable = error {
				self.changeModeIcon(to: .Disconnected)
				self.updateMainView()
			}
		}.finally {
			// Hide loading indicator.
			self.offButton.loadingIndicator(show: false)
		}
    }
    
    @IBAction func touchSwitchDeviceButton(_ sender: UIButton) {
		print("func touchSwitchDeviceButton()")
        var direction: SwitchDirection?
        
        if sender.tag == 6 {
            direction = .left
        } else if sender.tag == 7 {
            direction = .right
        }
        switchDevice(with: direction!)
    }
    
    func switchDevice(with direction: SwitchDirection) {
		let currentIndex = getCurrentDeviceViewModelIndex()
		var newIndex = currentIndex
		
		print("currentIndex: \(currentIndex)")
		
		// If no deviceViewModels exist, return nil
		if deviceViewModels == nil { return }
		if deviceViewModels!.count < 1 { return }
		
        switch direction {
		case .left:
			if currentIndex + 1 == deviceViewModels!.endIndex {
				newIndex = 0
			} else {
				newIndex += 1
			}
		case .right:
			if currentIndex - 1 < deviceViewModels!.startIndex {
				newIndex = deviceViewModels!.endIndex - 1
			} else {
				newIndex -= 1
			}
		}
		
		print("newIndex: \(newIndex)")
		
		// Update local devices
		var deviceList = try! DeviceManager.Local.getDeviceList()
		currentDeviceId = deviceList[newIndex].id
		try! DeviceManager.Local.saveDeviceList(deviceList: deviceList)
		
		// Update view (with local data)
        self.updateMainView()
		
		// Update current shown device with new status data and update view again
		self.updateCurrentDevice()
    }
    
}

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

extension UIButton {
    func loadingIndicator(show: Bool) {
        if show {
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.style = .whiteLarge
            self.addSubview(indicator)
            indicator.startAnimating()
            
            // Change background image.
            switch self.tag {
            case 1:
                self.setImage(UIImage(named: "icon-abitwarm-2-bg"), for: UIControl.State.normal)
            case 2:
                self.setImage(UIImage(named: "icon-abitcold-2-bg"), for: UIControl.State.normal)
            case 3:
                self.setImage(UIImage(named: "icon-comfort-bg"), for: UIControl.State.normal)
            case 4:
                self.setImage(UIImage(named: "icon-off-bg"), for: UIControl.State.normal)
            default:
                print("ERRR Something went wrong")
                return
            }
        } else {
            for view in self.subviews {
                if let indicator = view as? UIActivityIndicatorView {
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                    
                    // Change background image.
                    switch self.tag {
                    case 1:
                        self.setImage(UIImage(named: "icon-abitwarm-2"), for: UIControl.State.normal)
                    case 2:
                        self.setImage(UIImage(named: "icon-abitcold-2"), for: UIControl.State.normal)
                    case 3:
                        self.setImage(UIImage(named: "icon-comfort"), for: UIControl.State.normal)
                    case 4:
                        self.setImage(UIImage(named: "icon-off"), for: UIControl.State.normal)
                    default:
                        print("ERRR Something went wrong")
                        return
                    }
                }
            }
        }
    }
}
