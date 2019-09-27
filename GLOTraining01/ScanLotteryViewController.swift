//
//  ScanLotteryViewController.swift
//  GLOTraining01
//
//  Created by Tanapong Borrirakwisitsak on 27/9/2562 BE.
//  Copyright © 2562 ClickNext. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import IHProgressHUD
import AVFoundation

class ScanLotteryViewController: UIViewController {
	
	@IBOutlet weak var barCodeView: QRCodeReaderView!
		lazy var reader: QRCodeReader = QRCodeReader(metadataObjectTypes: [
			.qr
	//		, .upce
	//		, .code39
	//		, .code39Mod43
	//		, .code93
	//		, .code128
	//		, .ean8
	//		, .ean13
	//		, .aztec
	//		, .pdf417
	//		, .itf14
	//		, .interleaved2of5
			, .dataMatrix
			], captureDevicePosition: .back)
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.setupPreviewView()
		
    }
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.startScan()
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		self.reader.stopScanning()
		
		super.viewWillDisappear(animated)
	}
	
	func setupPreviewView() {
		
		self.barCodeView.setupComponents(with: QRCodeReaderViewControllerBuilder {
			$0.reader                 = self.reader
			$0.showTorchButton        = false
			$0.showSwitchCameraButton = false
			$0.showCancelButton       = false
			$0.showOverlayView        = false
			$0.rectOfInterest         = CGRect(x: 0, y: 0, width: 1, height: 1)
		})
		
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

extension ScanLotteryViewController : QRCodeReaderViewControllerDelegate {
	
	func scanBarcodeFinishAction(result: QRCodeReaderResult){
		
		let qrData = result.value
		print(qrData)
		let alert = UIAlertController(
			title: "QRCodeReader",
			message: String (format:"%@\n(of type %@)", result.value, result.metadataType),
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (alert) in
			
			self.startScan()
		}))
		self.present(alert, animated: true, completion: nil)
		
	}
	
	func startScan() {
		guard self.checkScanPermissions(), !self.reader.isRunning else { return }
		
		self.reader.didFindCode = { result in
			print("Completion with result: \(result.value) of type \(result.metadataType)")
			self.scanBarcodeFinishAction(result: result)
		}
		
		self.reader.startScanning()
	}
	
	private func checkScanPermissions() -> Bool {
		do {
			return try QRCodeReader.supportsMetadataObjectTypes()
		} catch let error as NSError {
			let alert: UIAlertController
			
			switch error.code {
			case -11852:
				
				alert = UIAlertController(title: "", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)

				alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
					DispatchQueue.main.async {
						if let settingsURL = URL(string: UIApplication.openSettingsURLString) {

							if #available(iOS 10.0, *) {
								UIApplication.shared.open(settingsURL, options: [:], completionHandler: { (success) in

								})
							}else{
								UIApplication.shared.openURL(settingsURL)
							}
						}
					}
				}))

				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
			default:
				alert = UIAlertController(title: "", message: "Reader not supported by the current device", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
			}
			
			present(alert, animated: true, completion: nil)
			
			return false
		}
	}
	
	func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
		
	}
	
	func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
		print("Switching capture to: \(newCaptureDevice.device.localizedName)")
	}
	
	func readerDidCancel(_ reader: QRCodeReaderViewController) {
		reader.stopScanning()
		
		dismiss(animated: true, completion: nil)
	}
	
}
