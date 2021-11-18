//
//  CameraController.swift
//  Plugin
//
//  Created by Ariel Hernandez Musa on 7/14/19.
//  Copyright © 2019 Max Lynch. All rights reserved.
//

import AVFoundation
import UIKit
import CoreMotion

class CameraController: NSObject {
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashView: UIView!
    
    var flashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    var highResolutionOutput: Bool = false
    
    var orientation:UIInterfaceOrientation = UIInterfaceOrientation.portrait
    var isOpenedFromPortraitMode:Bool = UIDevice.current.orientation.isPortrait
    
    var motionManager: CMMotionManager!
    var lastZoomFactor: CGFloat = 1.0
    var defaultZoomFactorForBackCamera: CGFloat = 1.0
    var defaultZoomFactorForFrontCamera: CGFloat = 1.0
    var isUltraWideCamera = false;
}

extension CameraController {
    func getFrontCameraDevices() -> [AVCaptureDevice] {
        var deviceTypes = [AVCaptureDevice.DeviceType]()
        deviceTypes.append(contentsOf: [.builtInWideAngleCamera])
        return AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .front).devices
    }
    
    func getBackCameraDevices() -> [AVCaptureDevice] {
        var deviceTypes = [AVCaptureDevice.DeviceType]()
        
        if #available(iOS 13.0, *) {
            deviceTypes.append(contentsOf: [.builtInDualWideCamera])
            self.isUltraWideCamera = true
            self.defaultZoomFactorForBackCamera = 2.0
        }
        
        if(deviceTypes.isEmpty){
            deviceTypes.append(contentsOf: [.builtInWideAngleCamera])
            self.isUltraWideCamera = false
            self.defaultZoomFactorForBackCamera = 1.0
        }
        
        return AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes, mediaType: .video, position: .back).devices
    }
    
    func loadFrontCamera(){
        let frontCameras = getFrontCameraDevices()
        if(frontCameras.isEmpty){
            return;
        }

        for camera in frontCameras {
            self.frontCamera = camera
        }
    }
    
    func loadBackCamera() throws {
        let backCameras = getBackCameraDevices()
        guard !backCameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
        
        for camera in backCameras {
            self.rearCamera = camera
            
            try camera.lockForConfiguration()
            camera.focusMode = .continuousAutoFocus
            camera.unlockForConfiguration()
        }
    }
    
    func detectOrientationByAccelerometer() {
        let splitAngle:Double = 0.75
        let updateTimer:TimeInterval = 0.5
        
        motionManager = CMMotionManager()
        motionManager?.gyroUpdateInterval = updateTimer
        motionManager?.accelerometerUpdateInterval = updateTimer
        
        var orientationLast = UIInterfaceOrientation(rawValue: 0)!
        
        if motionManager.isAccelerometerAvailable {
            motionManager?.startAccelerometerUpdates(to: OperationQueue.current ?? OperationQueue.main, withHandler: {
                (acceleroMeterData, error) -> Void in
                if error == nil {
                    let acceleration = (acceleroMeterData?.acceleration)!
                    var orientationNew = UIInterfaceOrientation(rawValue: 0)!
                    
                    if acceleration.x >= splitAngle {
                        orientationNew = .landscapeLeft
                    }
                    else if acceleration.x <= -(splitAngle) {
                        orientationNew = .landscapeRight
                    }
                    else if acceleration.y <= -(splitAngle) {
                        orientationNew = .portrait
                    }
                    else if acceleration.y >= splitAngle {
                        orientationNew = .portraitUpsideDown
                    }
                    
                    if orientationNew != orientationLast && orientationNew != .unknown{
                        orientationLast = orientationNew
                        self.deviceOrientationChanged(orientation: orientationNew)
                    }
                }
                else {
                    print("error : \(error!)")
                }
            })
        }
    }
    
    func deviceOrientationChanged(orientation:UIInterfaceOrientation) {
        self.orientation = orientation;
    }
    
    func addGestureForZoomAndFocus(on view: UIView){
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinch)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)
    }
    
    func prepare(cameraPosition: String, completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
            self.captureSession?.sessionPreset = .photo
        }
        
        func configureCaptureDevices() throws {
            try self.loadBackCamera()
            self.loadFrontCamera()
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if cameraPosition == "rear" {
                if let rearCamera = self.rearCamera {
                    self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                    
                    if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                    
                    self.currentCameraPosition = .rear
                }
            } else if cameraPosition == "front" {
                if let frontCamera = self.frontCamera {
                    self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                    
                    if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                    else { throw CameraControllerError.inputsAreInvalid }
                    
                    self.currentCameraPosition = .front
                }
            } else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            self.photoOutput?.isHighResolutionCaptureEnabled = self.highResolutionOutput
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            captureSession.startRunning()
        }
    
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
            
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        let videoOrientation: AVCaptureVideoOrientation
        
        switch (orientation) {
        case .portrait:
            videoOrientation = .portrait
        case .landscapeRight:
            videoOrientation = .landscapeLeft
        case .landscapeLeft:
            videoOrientation = .landscapeRight
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
        case .faceUp, .faceDown:
            switch (statusBarOrientation) {
            case .portrait:
                videoOrientation = .portrait
            case .landscapeRight:
                videoOrientation = .landscapeRight
            case .landscapeLeft:
                videoOrientation = .landscapeLeft
            case .portraitUpsideDown:
                videoOrientation = .portraitUpsideDown
            default:
                videoOrientation = .portrait
            }
        default:
            videoOrientation = .portrait
        }
        
        self.previewLayer?.connection?.videoOrientation = videoOrientation

        self.previewLayer?.frame = view.bounds;
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                  let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)

                self.currentCameraPosition = .front
                self.resetZoom()
            }
            else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                  let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)

                self.currentCameraPosition = .rear
                self.resetZoom()
            }
            
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        UIView.animate(withDuration: 0.1, delay: 0, animations: { () -> Void in
            self.flashView.alpha = 1
        }, completion: nil)
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        settings.isHighResolutionPhotoEnabled = self.highResolutionOutput;
        
        let videoOrientation: AVCaptureVideoOrientation
        if self.orientation == .portrait {
            videoOrientation = AVCaptureVideoOrientation.portrait
        }else if (self.orientation == .landscapeLeft){
            videoOrientation = AVCaptureVideoOrientation.landscapeLeft
        }else if (self.orientation == .landscapeRight){
            videoOrientation = AVCaptureVideoOrientation.landscapeRight
        }else if (self.orientation == .portraitUpsideDown){
            videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
        }else {
            videoOrientation = AVCaptureVideoOrientation.portrait
        }
        
        self.photoOutput?.connection(with: AVMediaType.video)?.videoOrientation = videoOrientation
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
        
        UIView.animate(withDuration: 0.1, delay: 0, animations: { () -> Void in
            self.flashView.alpha = 0
        }, completion: nil)
    }
    
    func getSupportedFlashModes() throws -> [String] {
        var currentCamera: AVCaptureDevice?
        switch currentCameraPosition {
        case .front:
            currentCamera = self.frontCamera!;
        case .rear:
            currentCamera = self.rearCamera!;
        default: break;
        }
        
        guard
            let device = currentCamera
        else {
            throw CameraControllerError.noCamerasAvailable
        }
        
        var supportedFlashModesAsStrings: [String] = []
        if device.hasFlash {
            guard let supportedFlashModes: [AVCaptureDevice.FlashMode] = self.photoOutput?.supportedFlashModes else {
                throw CameraControllerError.noCamerasAvailable
            }
            
            for flashMode in supportedFlashModes {
                var flashModeValue: String?
                switch flashMode {
                case AVCaptureDevice.FlashMode.off:
                    flashModeValue = "off"
                case AVCaptureDevice.FlashMode.on:
                    flashModeValue = "on"
                case AVCaptureDevice.FlashMode.auto:
                    flashModeValue = "auto"
                default: break;
                }
                if flashModeValue != nil {
                    supportedFlashModesAsStrings.append(flashModeValue!)
                }
            }
        }
        if device.hasTorch {
            supportedFlashModesAsStrings.append("torch")
        }
        return supportedFlashModesAsStrings
        
    }
    
    func setFlashMode(flashMode: AVCaptureDevice.FlashMode) throws {
        var currentCamera: AVCaptureDevice?
        switch currentCameraPosition {
        case .front:
            currentCamera = self.frontCamera!;
        case .rear:
            currentCamera = self.rearCamera!;
        default: break;
        }
        
        guard let device = currentCamera else {
            throw CameraControllerError.noCamerasAvailable
        }
        
        guard let supportedFlashModes: [AVCaptureDevice.FlashMode] = self.photoOutput?.supportedFlashModes else {
            throw CameraControllerError.invalidOperation
        }
        if supportedFlashModes.contains(flashMode) {
            do {
                try device.lockForConfiguration()
                
                if(device.hasTorch && device.isTorchAvailable && device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                }
                self.flashMode = flashMode
                let photoSettings = AVCapturePhotoSettings()
                photoSettings.flashMode = flashMode
                self.photoOutput?.photoSettingsForSceneMonitoring = photoSettings
                
                device.unlockForConfiguration()
            } catch {
                throw CameraControllerError.invalidOperation
            }
        } else {
            throw CameraControllerError.invalidOperation
        }
    }
    
    func setTorchMode() throws {
        var currentCamera: AVCaptureDevice?
        switch currentCameraPosition {
        case .front:
            currentCamera = self.frontCamera!;
        case .rear:
            currentCamera = self.rearCamera!;
        default: break;
        }
        
        guard
            let device = currentCamera,
            device.hasTorch,
            device.isTorchAvailable
        else {
            throw CameraControllerError.invalidOperation
        }
        
        do {
            try device.lockForConfiguration()
            if (device.isTorchModeSupported(AVCaptureDevice.TorchMode.on)) {
                device.torchMode = AVCaptureDevice.TorchMode.on
            } else if (device.isTorchModeSupported(AVCaptureDevice.TorchMode.auto)) {
                device.torchMode = AVCaptureDevice.TorchMode.auto
            } else {
                device.torchMode = AVCaptureDevice.TorchMode.off
            }
            device.unlockForConfiguration()
        } catch {
            throw CameraControllerError.invalidOperation
        }
        
    }
    
    @objc
    private func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        guard let device = self.currentCameraPosition == .rear ? rearCamera : frontCamera else { return }
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
                
            } catch {
                debugPrint(error)
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    
    func resetZoom() {
        guard let device = self.currentCameraPosition == .rear ? rearCamera : frontCamera else { return }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            self.lastZoomFactor = self.currentCameraPosition == .rear ? self.defaultZoomFactorForBackCamera : self.defaultZoomFactorForFrontCamera
            device.videoZoomFactor = self.lastZoomFactor
        } catch {
            debugPrint(error)
        }
    }
    
    @objc
    private func handleTap(_ tap: UITapGestureRecognizer) {
        guard let device = self.currentCameraPosition == .rear ? rearCamera : frontCamera else { return }
        
        let point = tap.location(in: tap.view)
        let devicePoint = self.previewLayer?.captureDevicePointConverted(fromLayerPoint: point)
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            let focusMode = AVCaptureDevice.FocusMode.autoFocus
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                device.focusPointOfInterest = CGPoint(x: CGFloat(devicePoint?.x ?? 0), y: CGFloat(devicePoint?.y ?? 0))
                device.focusMode = focusMode
            }
            
            let exposureMode = AVCaptureDevice.ExposureMode.autoExpose
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = CGPoint(x: CGFloat(devicePoint?.x ?? 0), y: CGFloat(devicePoint?.y ?? 0))
                device.exposureMode = exposureMode
            }
        } catch {
            debugPrint(error)
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
        else if let data = photo.fileDataRepresentation(),
                let image = UIImage(data: data) {
            self.photoCaptureCompletionBlock?(image, nil)
        }
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }
    }
}

enum CameraControllerError: Swift.Error {
    case captureSessionAlreadyRunning
    case captureSessionIsMissing
    case inputsAreInvalid
    case invalidOperation
    case noCamerasAvailable
    case noAccelerometerAvailable
    case unknown
}

public enum CameraPosition {
    case front
    case rear
}

extension CameraControllerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .captureSessionAlreadyRunning:
            return NSLocalizedString("Capture Session is Already Running", comment: "Capture Session Already Running")
        case .captureSessionIsMissing:
            return NSLocalizedString("Capture Session is Missing", comment: "Capture Session Missing")
        case .inputsAreInvalid:
            return NSLocalizedString("Inputs Are Invalid", comment: "Inputs Are Invalid")
        case .invalidOperation:
            return NSLocalizedString("Invalid Operation", comment: "invalid Operation")
        case .noCamerasAvailable:
            return NSLocalizedString("Failed to access device camera(s)", comment: "No Cameras Available")
        case .unknown:
            return NSLocalizedString("Unknown", comment: "Unknown")
        case .noAccelerometerAvailable:
            return NSLocalizedString("No accelerometer available", comment: "No accelerometer available")
        }
    }
}

extension UIImage {
    /**
     Generates a new image from the existing one, implicitly resetting any orientation.
     Dimensions greater than 0 will resize the image while preserving the aspect ratio.
     */
    func reformat(to size: CGSize? = nil) -> UIImage {
        let imageHeight = self.size.height
        let imageWidth = self.size.width
        
        // determine the max dimensions, 0 is treated as 'no restriction'
        var maxWidth: CGFloat
        if let size = size, size.width > 0 {
            maxWidth = size.width
        } else {
            maxWidth = imageWidth
        }
        let maxHeight: CGFloat
        if let size = size, size.height > 0 {
            maxHeight = size.height
        } else {
            maxHeight = imageHeight
        }
        // adjust to preserve aspect ratio
        var targetWidth = min(imageWidth, maxWidth)
        var targetHeight = (imageHeight * maxWidth) / imageWidth
        if targetHeight > maxHeight {
            targetWidth = (imageWidth * maxHeight) / imageHeight
            targetHeight = maxHeight
        }
        // generate the new image and return
        let format: UIGraphicsImageRendererFormat = UIGraphicsImageRendererFormat.default()
        format.scale = 1.0
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetWidth, height: targetHeight), format: format)
        return renderer.image { (_) in
            self.draw(in: CGRect(origin: .zero, size: CGSize(width: targetWidth, height: targetHeight)))
        }
    }
}
