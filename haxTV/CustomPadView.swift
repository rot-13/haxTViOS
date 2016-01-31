//
//  VirtualGameControllerSharedViews.swift
//
//
//  Created by Rob Reuss on 9/28/15.
//
//

import Foundation
import UIKit
import VirtualGameController
import AVFoundation

public let animationSpeed = 0.35

var peripheralManager = VgcManager.peripheral

// A simple mock-up of a game controller (Peripheral)
public class CustomPadView: NSObject {
    
    var custom = VgcManager.elements.custom
    var elements = VgcManager.elements
    public var parentView: UIView!
    public var controlOverlay: UIView!
    var controlLabel: UILabel!
    var activityIndicator : UIActivityIndicatorView!
    var playerIndexLabel: UILabel!
    var keyboardTextField: UITextField!
    var keyboardControlView: UIView!
    var keyboardLabel: UILabel!
    public var flashView: UIImageView!
    
    public var serviceSelectorView: ServiceSelectorView!
    
     public init(vc: UIViewController) {
        super.init()
        parentView = vc.view
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDidDisconnect:", name: VgcPeripheralDidDisconnectNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peripheralDidConnect:", name: VgcPeripheralDidConnectNotification, object: nil)
        
        parentView.backgroundColor = UIColor.darkGrayColor()
        
        flashView = UIImageView(frame: CGRect(x: 0, y: 0, width: parentView.bounds.size.width, height: parentView.bounds.size.height))
        flashView.backgroundColor = UIColor.redColor()
        flashView.alpha = 0
        flashView.userInteractionEnabled = false
        parentView.addSubview(flashView)
 
        parentView.backgroundColor = UIColor.init(red:147, green:158, blue:127, alpha: 1.0)
        let dpadSize = parentView.bounds.size.height * 0.50
        
        let leftThumbstickPad = VgcStick(frame: CGRect(x: (parentView.bounds.size.width - dpadSize) * 0.50, y: 24, width: dpadSize, height: parentView.bounds.size.height * 0.50), xElement: elements.dpadXAxis, yElement: elements.dpadYAxis)
 
        leftThumbstickPad.backgroundColor = UIColor.redColor()
        leftThumbstickPad.controlView.backgroundColor = UIColor.blackColor()
        parentView.addSubview(leftThumbstickPad)
        
        let buttonHeight = parentView.bounds.size.height * 0.20
        
        let xButton = VgcButton(frame: CGRect(x: 0, y: parentView.bounds.size.height - buttonHeight - 10, width: parentView.bounds.width, height: buttonHeight), element: elements.buttonX)
        xButton.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleTopMargin]
        xButton.valueLabel.textAlignment = .Right
        xButton.nameLabel.font = UIFont(name: xButton.nameLabel.font.fontName, size: 40)
        xButton.valueLabel.font = UIFont(name: xButton.valueLabel.font.fontName, size: 20)
        xButton.baseGrayShade = 0.08
        xButton.nameLabel.textColor = UIColor.lightGrayColor()
        xButton.valueLabel.textColor = UIColor.lightGrayColor()
        parentView.addSubview(xButton)
       
        controlOverlay = UIView(frame: CGRect(x: 0, y: 0, width: parentView.bounds.size.width, height: parentView.bounds.size.height))
        controlOverlay.backgroundColor = UIColor.blackColor()
        controlOverlay.alpha = 0.9
        parentView.addSubview(controlOverlay)
        
        controlLabel = UILabel(frame: CGRect(x: 0, y: controlOverlay.bounds.size.height * 0.35, width: controlOverlay.bounds.size.width, height: 25))
        controlLabel.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin , UIViewAutoresizing.FlexibleBottomMargin]
        controlLabel.text = "Seeking Centrals..."
        controlLabel.textAlignment = .Center
        controlLabel.textColor = UIColor.whiteColor()
        controlLabel.font = UIFont(name: controlLabel.font.fontName, size: 20)
        controlOverlay.addSubview(controlLabel)
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, controlOverlay.bounds.size.height * 0.40, controlOverlay.bounds.size.width, 50)) as UIActivityIndicatorView
        activityIndicator.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin , UIViewAutoresizing.FlexibleBottomMargin]
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        controlOverlay.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        serviceSelectorView = ServiceSelectorView(frame: CGRectMake(25, controlOverlay.bounds.size.height * 0.50, controlOverlay.bounds.size.width - 50, controlOverlay.bounds.size.height - 200))
        serviceSelectorView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , UIViewAutoresizing.FlexibleRightMargin]
        controlOverlay.addSubview(serviceSelectorView)
        
        
    }
    
     func peripheralDidConnect(notification: NSNotification) {
        vgcLogDebug("Animating control overlay up")
        UIView.animateWithDuration(animationSpeed, delay: 0.0, options: .CurveEaseIn, animations: {
            self.controlOverlay.frame = CGRect(x: 0, y: -self.parentView.bounds.size.height, width: self.parentView.bounds.size.width, height: self.parentView.bounds.size.height)
            }, completion: { finished in
                
        })
        
        
    }
    
    #if !os(tvOS)
     func peripheralDidDisconnect(notification: NSNotification) {
        vgcLogDebug("Animating control overlay down")
        UIView.animateWithDuration(animationSpeed, delay: 0.0, options: .CurveEaseIn, animations: {
            self.controlOverlay.frame = CGRect(x: 0, y: 0, width: self.parentView.bounds.size.width, height: self.parentView.bounds.size.height)
            }, completion: { finished in
                self.serviceSelectorView.refresh()
        })
    }
    #endif
    
    func playerTappedToShowKeyboard(sender: AnyObject) {
        
        if VgcManager.iCadeControllerMode != .Disabled { return }
        
        keyboardControlView = UIView(frame: CGRect(x: 0, y: parentView.bounds.size.height, width: parentView.bounds.size.width, height: parentView.bounds.size.height))
        keyboardControlView.backgroundColor = UIColor.darkGrayColor()
        parentView.addSubview(keyboardControlView)
        
        let dismissKeyboardGR = UITapGestureRecognizer(target: self, action:Selector("dismissKeyboard"))
        keyboardControlView.gestureRecognizers = [dismissKeyboardGR]
        
        keyboardLabel = UILabel(frame: CGRect(x: 0, y: 0, width: keyboardControlView.bounds.size.width, height: keyboardControlView.bounds.size.height * 0.60))
        keyboardLabel.text = ""
        keyboardLabel.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin]
        keyboardLabel.textColor = UIColor.whiteColor()
        keyboardLabel.textAlignment = .Center
        keyboardLabel.font = UIFont(name: keyboardLabel.font.fontName, size: 40)
        keyboardLabel.adjustsFontSizeToFitWidth = true
        keyboardLabel.numberOfLines = 5
        keyboardControlView.addSubview(keyboardLabel)
        
        UIView.animateWithDuration(animationSpeed, delay: 0.0, options: .CurveEaseIn, animations: {
            self.keyboardControlView.frame = self.parentView.bounds
            }, completion: { finished in
        })
        
        keyboardTextField.becomeFirstResponder()
        
    }
    
    func dismissKeyboard() {
        
        keyboardTextField.resignFirstResponder()
        UIView.animateWithDuration(animationSpeed, delay: 0.0, options: .CurveEaseIn, animations: {
            self.keyboardControlView.frame = CGRect(x: 0, y: self.parentView.bounds.size.height, width: self.parentView.bounds.size.width, height: self.parentView.bounds.size.height)
            }, completion: { finished in
        })
    }
    
    func textFieldDidChange(sender: AnyObject) {
        
        if VgcManager.iCadeControllerMode != .Disabled {
            
            vgcLogDebug("Sending iCade character: \(keyboardTextField.text) using iCade mode: \(VgcManager.iCadeControllerMode.description)")
            
            var element: Element!
            var value: Int
            (element, value) = VgcManager.iCadePeripheral.elementForCharacter(keyboardTextField.text!, controllerElements: elements)
            keyboardTextField.text = ""
            if element == nil { return }
            element.value = value
            VgcManager.peripheral.sendElementState(element)
            
        } else {
            
            keyboardLabel.text = keyboardTextField.text!
            VgcManager.elements.custom[CustomElementType.Keyboard.rawValue]!.value = keyboardTextField.text!
            VgcManager.peripheral.sendElementState(VgcManager.elements.custom[CustomElementType.Keyboard.rawValue]!)
            keyboardTextField.text = ""
            
        }
        
    }
}

// Provides a view over the Peripheral control pad that allows the end user to
// select which Central/Bridge to connect to.
public class ServiceSelectorView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        tableView = UITableView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        tableView.layer.cornerRadius = 20.0
        tableView.backgroundColor = UIColor.clearColor()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 44.0
        self.addSubview(tableView)
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    public func refresh() {
        vgcLogDebug("Refreshing server selector view")
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.frame = CGRectMake(0, 0, tableView.bounds.size.width, CGFloat(tableView.rowHeight) * CGFloat(VgcManager.peripheral.availableServices.count))
        return VgcManager.peripheral.availableServices.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let serviceName = VgcManager.peripheral.availableServices[indexPath.row].fullName
        cell.textLabel?.font = UIFont(name: cell.textLabel!.font.fontName, size: 16)
        cell.textLabel?.text = serviceName
        cell.backgroundColor = UIColor.grayColor()
        cell.alpha = 1.0
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        return cell
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if VgcManager.peripheral.availableServices.count > 0 {
            let service = VgcManager.peripheral.availableServices[indexPath.row]
            VgcManager.peripheral.connectToService(service)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// Basic button element, with support for 3d touch
class VgcButton: UIView {
    
    let element: Element!
    var nameLabel: UILabel!
    var valueLabel: UILabel!
    var _baseGrayShade: Float = 0.76
    var baseGrayShade: Float {
        get {
            return _baseGrayShade
        }
        set {
            _baseGrayShade = newValue
            self.backgroundColor = UIColor(white: CGFloat(_baseGrayShade), alpha: 1.0)
        }
    }
    
    var value: Float {
        get {
            return self.value
        }
        set {
            self.value = newValue
        }
    }
    
    init(frame: CGRect, element: Element) {
        
        self.element = element
        
        super.init(frame: frame)
        
        baseGrayShade = 0.76
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        nameLabel.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , UIViewAutoresizing.FlexibleHeight]
        nameLabel.text = element.name
        nameLabel.textAlignment = .Center
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 20)
        self.addSubview(nameLabel)
        
        valueLabel = UILabel(frame: CGRect(x: 10, y: frame.size.height * 0.70, width: frame.size.width - 20, height: frame.size.height * 0.30))
        valueLabel.autoresizingMask = [UIViewAutoresizing.FlexibleWidth , UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleTopMargin]
        valueLabel.text = "0.0"
        valueLabel.textAlignment = .Center
        valueLabel.font = UIFont(name: valueLabel.font.fontName, size: 10)
        valueLabel.textAlignment = .Right
        self.addSubview(valueLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func percentageForce(touch: UITouch) -> Float {
        let force = Float(touch.force)
        let maxForce = Float(touch.maximumPossibleForce)
        let percentageForce: Float
        if (force == 0) { percentageForce = 0 } else { percentageForce = force / maxForce }
        return percentageForce
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        
        // If 3d touch is not supported, just send a "1" value
        if (self.traitCollection.forceTouchCapability == .Available) {
            element.value = self.percentageForce(touch!)
            valueLabel.text = "\(element.value)"
            let colorValue = CGFloat(baseGrayShade - (element.value as! Float / 10))
            self.backgroundColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1)
        } else {
            element.value = 1.0
            valueLabel.text = "\(element.value)"
            self.backgroundColor = UIColor(red: 0.30, green: 0.30, blue: 0.30, alpha: 1)
        }
        VgcManager.peripheral.sendElementState(element)
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        
        // If 3d touch is not supported, just send a "1" value
        if (self.traitCollection.forceTouchCapability == .Available) {
            element.value = self.percentageForce(touch!)
            valueLabel.text = "\(element.value)"
            let colorValue = CGFloat(baseGrayShade - (element.value as! Float) / 10)
            self.backgroundColor = UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1)
        } else {
            element.value = 1.0
            valueLabel.text = "\(element.value)"
            self.backgroundColor = UIColor(red: 0.30, green: 0.30, blue: 0.30, alpha: 1)
        }
        
        VgcManager.peripheral.sendElementState(element)
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        element.value = 0.0
        valueLabel.text = "\(element.value)"
        VgcManager.peripheral.sendElementState(element)
        self.backgroundColor = UIColor(white: CGFloat(baseGrayShade), alpha: 1.0)
        
    }
    
}

class VgcStick: UIView {
    
    let xElement: Element!
    let yElement: Element!
    
    var controlView: UIView!
    var touchesView: UIView!
    
    var value: Float {
        get {
            return self.value
        }
        set {
            self.value = newValue
        }
    }
    
    init(frame: CGRect, xElement: Element, yElement: Element) {
        
        self.xElement = xElement
        self.yElement = yElement
        
        super.init(frame: frame)
        
        let controlViewSide = frame.height * 0.40
        controlView = UIView(frame: CGRect(x: controlViewSide, y: controlViewSide, width: controlViewSide, height: controlViewSide))
        controlView.layer.cornerRadius = controlView.bounds.size.width / 2
        controlView.backgroundColor = UIColor.blackColor()
        self.addSubview(controlView)
        
        self.backgroundColor = peripheralBackgroundColor
        self.layer.cornerRadius = frame.width / 2
        
        self.centerController(0.0)
   
        touchesView = controlView
        controlView.userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func percentageForce(touch: UITouch) -> Float {
        let force = Float(touch.force)
        let maxForce = Float(touch.maximumPossibleForce)
        let percentageForce: Float
        if (force == 0) { percentageForce = 0 } else { percentageForce = force / maxForce }
        return percentageForce
    }
    
    func processTouch(touch: UITouch!) {
        
        if touch!.view == touchesView {
        
            
            // Prevent the stick from leaving the view center area
            var newX = touch!.locationInView(self).x
            var newY = touch!.locationInView(self).y
            let movementMarginSize = self.bounds.size.width * 0.25
            if newX < movementMarginSize { newX = movementMarginSize}
            if newX > self.bounds.size.width - movementMarginSize { newX = self.bounds.size.width - movementMarginSize }
            if newY < movementMarginSize { newY = movementMarginSize }
            if newY > self.bounds.size.height - movementMarginSize { newY = self.bounds.size.height - movementMarginSize }
            controlView.center = CGPoint(x: newX, y: newY)
            
            // Regularize the value between -1 and 1
            let rangeSize = self.bounds.size.height - (movementMarginSize * 2.0)
            let xValue = (((newX / rangeSize) - 0.5) * 2.0) - 1.0
            var yValue = (((newY / rangeSize) - 0.5) * 2.0) - 1.0
            yValue = -(yValue)
            
            xElement.value = Float(xValue)
            yElement.value = Float(yValue)
            VgcManager.peripheral.sendElementState(xElement)
            VgcManager.peripheral.sendElementState(yElement)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        self.processTouch(touch)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        if touch!.view == touchesView {
            self.centerController(0.1)
        }
        xElement.value = Float(0)
        yElement.value = Float(0)
        VgcManager.peripheral.sendElementState(xElement)
        VgcManager.peripheral.sendElementState(yElement)
    }
    
    // Re-center the control element
    func centerController(duration: Double) {
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseIn, animations: {
            self.controlView.center = CGPoint(x: ((self.bounds.size.height * 0.50)), y: ((self.bounds.size.width * 0.50)))
            }, completion: { finished in
                
        })
    }
}

