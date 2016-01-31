//
//  ViewController.swift
//  haxTV
//
//  Created by Davidson, Shay on 31/01/2016.
//  Copyright © 2016 CPC. All rights reserved.
//

import UIKit
import VirtualGameController
import GameController

class ViewController: UIViewController {
    
    var peripheralControlPadView: CustomPadView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        VgcManager.loggerUseNSLog = true
        VgcManager.startAs(.Peripheral, appIdentifier: "haxtv", includesPeerToPeer: true)
        VgcManager.peripheral.deviceInfo = DeviceInfo(deviceUID: "", vendorName: "shay", attachedToDevice: false, profileType: .ExtendedGamepad, controllerType: .Software, supportsMotion: false)
        
        peripheralControlPadView = CustomPadView(vc: self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDidDisconnect:", name: VgcPeripheralDidDisconnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDidConnect:", name: VgcPeripheralDidConnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralConnectionFailed:", name: VgcPeripheralConnectionFailedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedSystemMessage:", name: VgcSystemMessageNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "foundService:", name: VgcPeripheralFoundService, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedPeripheralSetup:", name: VgcPeripheralSetupNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "lostService:", name: VgcPeripheralLostService, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "serviceBrowserReset:", name: VgcPeripheralDidResetBrowser, object: nil)
        
        VgcManager.peripheral.browseForServices()
        
        VgcManager.includesPeerToPeer = true        
    }
    
    // Add new service to our list of available services.  I'm not using here, but the
    // newly found VgcService object is included with the notification.
    func foundService(notification: NSNotification) {
        let vgcService = notification.object as! VgcService
        vgcLogDebug("Found service: \(vgcService.fullName) isMainThread: \(NSThread.isMainThread())")
        peripheralControlPadView.serviceSelectorView.refresh()
    }
    
    // Refresh list of available services because one went offline.
    // I'm not using here, but the lost VgcService object is included with the notification.
    func lostService(notification: NSNotification) {
        let vgcService = notification.object as? VgcService
        vgcLogDebug("Lost service: \(vgcService!.fullName) isMainThread: \(NSThread.isMainThread())")
        peripheralControlPadView.serviceSelectorView.refresh()
    }
    
    // Notification indicates we should refresh the view
    func serviceBrowserReset(notification: NSNotification) {
        vgcLogDebug("Service browser reset, isMainThread: \(NSThread.isMainThread())")
        peripheralControlPadView.serviceSelectorView.refresh()
    }
    
    // Notification indicates connection failed
    func peripheralConnectionFailed(notification: NSNotification) {
        vgcLogDebug("Peripheral connect failed, isMainThread: \(NSThread.isMainThread())")
        peripheralControlPadView.serviceSelectorView.refresh()
    }
    
    // The Central has sent PeripheralSetup information
    func receivedPeripheralSetup(notification: NSNotification) {
        VgcManager.peripheral.deviceInfo.profileType = VgcManager.peripheralSetup.profileType
        print(VgcManager.peripheralSetup)
        for view in peripheralControlPadView.parentView.subviews {
            view.removeFromSuperview()
        }
        peripheralControlPadView = CustomPadView(vc: self)
        peripheralControlPadView.controlOverlay.frame = CGRect(x: 0, y: -peripheralControlPadView.parentView.bounds.size.height, width: peripheralControlPadView.parentView.bounds.size.width, height: peripheralControlPadView.parentView.bounds.size.height)
        
        peripheralControlPadView.parentView.backgroundColor = VgcManager.peripheralSetup.backgroundColor
    }
    
    
    func receivedSystemMessage(notification: NSNotification) {
        let systemMessageTypeRaw = notification.object as! Int
        let systemMessageType = SystemMessages(rawValue: systemMessageTypeRaw)
        if systemMessageType == SystemMessages.ReceivedInvalidMessage {
            
            // Flash the UI red to indicate bad messages being sent
            self.peripheralControlPadView.flashView.backgroundColor = UIColor.redColor()
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseIn, animations: {
                self.peripheralControlPadView.flashView!.alpha = 1
                }, completion: { finished in
                    self.peripheralControlPadView.flashView!.alpha = 0
            })
            
        }
    }
    
    func peripheralDidConnect(notification: NSNotification) {
        vgcLogDebug("Got VgcPeripheralDidConnectNotification notification")
        VgcManager.peripheral.stopBrowsingForServices()
    }
    
    func peripheralDidDisconnect(notification: NSNotification) {
        vgcLogDebug("Got VgcPeripheralDidDisconnectNotification notification")
        VgcManager.peripheral.browseForServices()
        
    }
}

