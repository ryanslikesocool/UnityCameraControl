import AVKit
import Foundation
import OSLog

final class UnityCameraService: NSObject {
	let key: CameraServiceKey

	let captureSession: AVCaptureSession

	private(set) var controlsDelegate: (any AVCaptureSessionControlsDelegate)?

	private(set) var presentControls: Set<CaptureControlKey>

	init(key: CameraServiceKey) throws {
		self.key = key
		captureSession = AVCaptureSession()
		presentControls = []
		controlsDelegate = nil

		super.init()

		try configureCaptureSession { captureSession in
			// both input and output are required to run the session
			try Self.addDefaultInput(captureSession)
			try Self.addDefaultOutput(captureSession)
		}

		Self.logMessage("\(Self.self) initialized.")
	}

	// MARK: - Utility

	private static func logMessage(
		level: OSLogType = .debug,
		function: StaticString = #function,
		_ message: @autoclosure @escaping () -> String
	) { 
		LogCategory.cameraService.log(level: level, function: function, message())
	}

	/// Add the default capture session input.
	/// - Important: This must be called inside a ``configureCaptureSession(:)`` block.
	private static func addDefaultInput(_ captureSession: AVCaptureSession) throws {
		// https://developer.apple.com/documentation/avfoundation/capture_setup/setting_up_a_capture_session
		guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) else {
			throw ConfigurationFailure.missingDevice
		}
		let deviceInput = try AVCaptureDeviceInput(device: device)
		guard captureSession.canAddInput(deviceInput) else {
			throw ConfigurationFailure.cannotAddInput
		}
		captureSession.addInput(deviceInput)
	}

	/// Add the default capture session output.
	/// - Important: This must be called inside a ``configureCaptureSession(:)`` block.
	private static func addDefaultOutput(_ captureSession: AVCaptureSession) throws {
		let photoOutput = AVCapturePhotoOutput()
		guard captureSession.canAddOutput(photoOutput) else {
			throw ConfigurationFailure.cannotAddOutput
		}
		captureSession.sessionPreset = .photo
		captureSession.addOutput(photoOutput)
	}

	private func configureCaptureSession<Result>(
		body: (AVCaptureSession) throws -> Result
	) rethrows -> Result {
		captureSession.beginConfiguration()
		defer { captureSession.commitConfiguration() }

		return try body(captureSession)
	}

	// MARK: - Add / Remove Controls

	func setControlsDelegate(_ controlsDelegate: (any AVCaptureSessionControlsDelegate)?) {
		self.controlsDelegate = controlsDelegate
		captureSession.setControlsDelegate(controlsDelegate, queue: .main)
	}

	func setControls(_ keys: [CaptureControlKey]) throws { 
		guard captureSession.supportsControls else {
			throw AddControlFailure.unsupported
		}

		try configureCaptureSession { captureSession in 
			for control in captureSession.controls {
				captureSession.removeControl(control)
			}

			presentControls.removeAll()

			for key in keys {
				let control = try UnityCaptureControlManager.shared.getCaptureControl(key)
				guard captureSession.canAddControl(control) else {
					throw AddControlFailure.cannotAdd(key, Swift.type(of: control))
				}

				captureSession.addControl(control)
			}
		}		
	}

	func addControl(_ key: CaptureControlKey) throws {
		guard captureSession.supportsControls else {
			throw AddControlFailure.unsupported
		}
		guard !presentControls.contains(key) else {
			throw AddControlFailure.alreadyAdded(key)
		}
		let control = try UnityCaptureControlManager.shared.getCaptureControl(key)
		guard captureSession.canAddControl(control) else {
			throw AddControlFailure.cannotAdd(key, Swift.type(of: control))
		}

		configureCaptureSession { captureSession in
			captureSession.addControl(control)
		}
		presentControls.insert(key)
	}

	func removeControl(_ key: CaptureControlKey) throws {
		let control = try UnityCaptureControlManager.shared.getCaptureControl(key)
		guard presentControls.remove(key) != nil else {
			throw RemoveControlFailure.wasNotAdded(key)
		}

		configureCaptureSession { captureSession in
			captureSession.removeControl(control)
		}
	}

	func removeAllControls() {
		configureCaptureSession { captureSession in
			for control in captureSession.controls {
				captureSession.removeControl(control)
			}
		}
		presentControls.removeAll()
		//controls.removeAll()
	}
}

// MARK: - Errors

private extension UnityCameraService {
	enum ConfigurationFailure: Error {
		case missingDevice
		case cannotAddInput
		case cannotAddOutput
	}

	enum AddControlFailure: Error {
		case unsupported
		case cannotAdd(CaptureControlKey, AVCaptureControl.Type)
		case alreadyAdded(CaptureControlKey)
	}

	enum RemoveControlFailure: Error {
		case wasNotAdded(CaptureControlKey)
	}
}