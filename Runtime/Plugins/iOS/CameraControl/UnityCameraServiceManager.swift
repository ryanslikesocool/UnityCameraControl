import AVKit
import Foundation
import OSLog

@objc
public final class UnityCameraServiceManager: NSObject {
	@objc
	public static let shared: UnityCameraServiceManager = UnityCameraServiceManager()

	private var keyGenerator: SimpleKeyGenerator<CameraServiceKey, CameraServiceKey>
	private var storage: [CameraServiceKey: UnityCameraService]

	public override init() {
		keyGenerator = SimpleKeyGenerator(in: CameraServiceKey.zero ... CameraServiceKey.max - 1)
		storage = [:]

		super.init()

		Self.logger.log("\(Self.self) initialized.")
	}
}

// MARK: - Errors

private extension UnityCameraServiceManager { 
	enum CameraServiceAccessFailure: Error {
		case missing(CameraServiceKey)
	}
}

// MARK: - Utility

extension UnityCameraServiceManager {
	private static let logger: LogCategory = .cameraService

	private func getCameraService(_ key: CameraServiceKey) throws -> UnityCameraService {
		guard let cameraService = storage[key] else {
			throw CameraServiceAccessFailure.missing(key)
		}
		return cameraService
	}

	private func tryGetCameraService(
		_ key: CameraServiceKey, 
		level: OSLogType = .error,
		function: StaticString = #function
	) -> UnityCameraService? {
		do {
			return try getCameraService(key)
		} catch {
			Self.logger.log(level: level, function: function, error: error, "Failed to access camera service with key \(key).")
			return nil
		}
	}

	private func withCameraService<Result>(
		_ key: CameraServiceKey, 
		body: (UnityCameraService) throws -> Result
	) rethrows -> Result {
		guard let cameraService = storage[key] else {
			preconditionFailure()
		}
		return try body(cameraService)
	}

	func assertSessionKey(_ session: AVCaptureSession, matches key: CameraServiceKey) {
		assert(storage[key]?.captureSession === session)
	}
}

// MARK: -

public extension UnityCameraServiceManager {
	// MARK: - Camera Service Management

	@objc
	func createService() -> CameraServiceKey {
		do {
			let key = try keyGenerator.generate(excluding: storage.keys)
			let cameraService = try UnityCameraService(key: key)
			storage[key] = cameraService
			Self.logger.log("Successfully created camera service with key \(key).")
			return key
		} catch {
			Self.logger.log(error: error, "Failed to create camera service.")
			return CameraServiceKey.max
		}
	}

	/// - Returns: `true` if the camera service with the given key was present and successfully destroyed; `false` otherwise.
	@objc
	func destroyService(_ key: CameraServiceKey) -> Bool {
		lazy var messageSuffix: String = "camera service with key \(key)."

		guard let cameraService = storage.removeValue(forKey: key) else {
			Self.logger.log(level: .error, "Failed to destroy \(messageSuffix)")
			return false
		}

		// TODO: finish cameraService deinitialization

		Self.logger.log("Successfully destroyed \(messageSuffix)")

		return true
	}

	/// - Returns: `true` if a camera service with the given `key` exists; `false` otherwise.
	@objc
	func containsService(_ key: CameraServiceKey) -> Bool {
		storage.keys.contains(key)
	}

	/// - Returns: `true` if the camera service with the given `key` is running; `false` otherwise.
	@objc
	func getIsRunning(_ key: CameraServiceKey) -> Bool {
		tryGetCameraService(key)?.captureSession.isRunning ?? false
	}

	@objc
	func setIsRunning(_ key: CameraServiceKey, newValue: Bool) {
		lazy var messageSuffix: String = "camera service with key \(key)."

		guard let captureSession = tryGetCameraService(key)?.captureSession else {
			return
		}
		
		switch (captureSession.isRunning, newValue) {
			case (false, true): 
				captureSession.startRunning()
				Self.logger.log("Started \(messageSuffix)")
			case (true, false): 
				captureSession.stopRunning()
				Self.logger.log("Stopped \(messageSuffix)")
			default:
				Self.logger.log("Did not change `isRunning` state for \(messageSuffix)")
				// same value, no change
				break
		}
	}

	typealias CaptureSessionControlsDelegateFunction = (CameraServiceKey) -> Void

	@objc
	func removeCaptureSessionControlsDelegate(
		_ cameraServiceKey: CameraServiceKey
	) -> Bool {
		lazy var messageSuffix: String = "controls delegate for camera service with key \(cameraServiceKey)."

		do {
			let cameraService = try getCameraService(cameraServiceKey)
			cameraService.setControlsDelegate(nil)
			Self.logger.log("Successfully removed \(messageSuffix)")
			return true
		} catch {
			Self.logger.log(error: error, "Failed to remove \(messageSuffix)")
			return false
		}
	}

	@objc
	func setCaptureSessionControlsDelegate(
		_ cameraServiceKey: CameraServiceKey,
		didBecomeActive: @escaping CaptureSessionControlsDelegateFunction, 
		didBecomeInactive: @escaping CaptureSessionControlsDelegateFunction,
		willEnterFullscreenAppearance: @escaping CaptureSessionControlsDelegateFunction,
		willExitFullscreenAppearance: @escaping CaptureSessionControlsDelegateFunction
	) -> Bool {
		lazy var messageSuffix: String = "set controls delegate for camera service with key \(cameraServiceKey)."

		do {
			let cameraService = try getCameraService(cameraServiceKey)
			let controlsDelegate = UnityCaptureControlsDelegate(
				key: cameraServiceKey,
				didBecomeActive: didBecomeActive,
				didBecomeInactive: didBecomeInactive,
				willEnterFullscreenAppearance: willEnterFullscreenAppearance,
				willExitFullscreenAppearance: willExitFullscreenAppearance
			)
			cameraService.setControlsDelegate(controlsDelegate)
			Self.logger.log("Successfully \(messageSuffix)")
			return true
		} catch {
			Self.logger.log(error: error, "Failed to \(messageSuffix)")
			return false
		}
	}

	// MARK: - Capture Control Management

	@objc
	func setControls(_ cameraServiceKey: CameraServiceKey, _ captureControlKeys: [CaptureControlKey]) -> Bool { 
		assert(captureControlKeys.isEmpty, "The provided capture control key array was empty.  Use `removeAllControls(:)` if the intent was to remove all controls.")

		lazy var captureControlCount: Int = captureControlKeys.count
		lazy var messageSuffix: String = "set \(captureControlCount) capture control\(captureControlCount > 1 ? "s" : "") on camera service with key \(cameraServiceKey)."

		do {
			let cameraService = try getCameraService(cameraServiceKey)
			try cameraService.setControls(captureControlKeys)
			Self.logger.log("Successfully \(messageSuffix)")
			return true
		} catch {	
			Self.logger.log(error: error, "Failed to \(messageSuffix)")
			return false
		}
	}

	@objc
	func addControl(_ cameraServiceKey: CameraServiceKey, _ captureControlKey: CaptureControlKey) -> Bool {
		lazy var messageSuffix: String = "capture control with key \(captureControlKey) to camera service with key \(cameraServiceKey)."

		do {
			let cameraService = try getCameraService(cameraServiceKey)			 
			try cameraService.addControl(captureControlKey)
			Self.logger.log("Successfully added \(messageSuffix)")
			return true
		} catch {
			Self.logger.log(error: error, "Failed to add \(messageSuffix)")
			return false
		}
	}

	@objc
	func removeControl(_ cameraServiceKey: CameraServiceKey, _ captureControlKey: CaptureControlKey) -> Bool {
		lazy var messageSuffix: String = "capture control with key \(captureControlKey) from camera service with key \(cameraServiceKey)."

		do {
			let cameraService = try getCameraService(cameraServiceKey)
			try cameraService.removeControl(captureControlKey)
			Self.logger.log("Successfully removed \(messageSuffix)")
			return true
		} catch {
			Self.logger.log(error: error, "Failed to remove \(messageSuffix)")
			return false
		}
	}

	@objc
	func removeAllControls(_ cameraServiceKey: CameraServiceKey) -> Bool {
		lazy var messageSuffix: String = "all controls from camera service with key \(cameraServiceKey)."

		do {
			let cameraService = try getCameraService(cameraServiceKey)			 
			cameraService.removeAllControls()
			Self.logger.log("Successfully removed \(messageSuffix)")
			return true
		} catch {
			Self.logger.log(error: error, "Failed to remove \(messageSuffix)")
			return false
		}
	}

	@objc
	func containsControl(_ cameraServiceKey: CameraServiceKey, _ captureControlKey: CaptureControlKey) -> Bool { 
		tryGetCameraService(cameraServiceKey)?.presentControls.contains(captureControlKey) ?? false
	}

	/// The maximum number of controls a camera service supports.
	/// - Returns: The maximum number of controls a camera service with the given `key` supports.
	@objc
	func getMaxControlsCount(_ cameraServiceKey: CameraServiceKey) -> Int {
		tryGetCameraService(cameraServiceKey)?.captureSession.maxControlsCount ?? Int.zero
	}

	/// A Boolean value that indicates whether a camera service supports controls.
	///
	/// A camera service supports controls only on platforms that provide the required hardware.
	/// - Returns: `true` if the camera service with the given `key` supports controls; `false` otherwise.
	@objc
	func getSupportsControls(_ cameraServiceKey: CameraServiceKey) -> Bool {
		tryGetCameraService(cameraServiceKey)?.captureSession.supportsControls ?? false
	}

	/// The current number of controls for a camera service.
	/// - Returns: The current number of controls for a camera service with the given `key`.
	@objc
	func getControlCount(_ cameraServiceKey: CameraServiceKey) -> Int {
		tryGetCameraService(cameraServiceKey)?.captureSession.controls.count ?? Int.zero
	}
}
