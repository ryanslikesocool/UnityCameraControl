import AVKit
import Foundation
import OSLog

@objc
public final class UnityCaptureControlManager: NSObject {
	public typealias Key = CaptureControlKey

	@objc
	public static let shared: UnityCaptureControlManager = UnityCaptureControlManager()

	private var keyGenerator: SimpleKeyGenerator<Key, Key>

	private var storage: [Key: AVCaptureControl]

	private override init() {
		keyGenerator = SimpleKeyGenerator(in: Key.min ... Key.max - 1)
		storage = [:]

		super.init()
	}
}

// MARK: - Errors

private extension UnityCaptureControlManager {
	enum CaptureControlAccessFailure: Error {
		case missing(Key)
		case cannotCast(Key, source: AVCaptureControl.Type, destination: AVCaptureControl.Type)
	}
}

// MARK: - Utility

extension UnityCaptureControlManager {
	private static let logger: LogCategory = .captureControl

	func getCaptureControl(_ key: Key) throws -> AVCaptureControl {
		guard let captureControl = storage[key] else {
			throw CaptureControlAccessFailure.missing(key)
		}
		return captureControl
	}

	func withCaptureControl<Control, Result>(
		_ key: Key,
		as type: Control.Type,
		body: (Control) throws -> Result
	) throws -> Result where
		Control: AVCaptureControl
	{
		let control = try getCaptureControl(key)
		guard let control = control as? Control else {
			throw CaptureControlAccessFailure.cannotCast(key, source: Swift.type(of: control), destination: Control.self)
		}
		return try body(control)
	}

	func tryWithCaptureControl<Control, Result>(
		_ key: Key,
		as type: Control.Type,
		level: OSLogType = .error,
		function: StaticString = #function,
		body: (Control) throws -> Result
	) -> Result? where
		Control: AVCaptureControl
	{
		do {
			return try withCaptureControl(key, as: type) { captureControl in
				try body(captureControl)
			}
		} catch {
			Self.logger.log(level: level, function: function, error: error)
			return nil
		}
	}
}

// MARK: - Storage Management

public extension UnityCaptureControlManager { 
	@nonobjc
	internal func createControl(_ control: AVCaptureControl) -> Key {
		do {
			let key = try keyGenerator.generate(excluding: storage.keys)
			storage[key] = control
			Self.logger.log("Successfully created capture control with key \(key).")
			return key
		} catch {
			Self.logger.log(error: error, "Failed to create capture control.")
			return Key.max
		}
	}


	@objc
	func destroyControl(_ key: Key) -> Bool {
		let result: Bool = storage.removeValue(forKey: key) != nil

		lazy var messageSuffix: String = "capture control with key \(key)."
		if result {
			Self.logger.log("Successfully destroyed \(messageSuffix)")
		} else {
			Self.logger.log("Failed to destroy \(messageSuffix)")
		}

		return result
	}

	@objc
	func containsControl(_ key: Key) -> Bool {
		storage.keys.contains(key)
	}

	@objc
	func getIsEnabled(_ key: Key) -> Bool {
		do {
			return try getCaptureControl(key).isEnabled
		} catch {
			Self.logger.log(error: error)
			return false
		}
	}

	@objc
	func setIsEnabled(_ key: Key, newValue: Bool) {
		lazy var messageBoolean: String = newValue ? "enable" : "disable"
		lazy var messageSuffix: String = "capture control with key \(key)."

		do {
			let captureControl = try getCaptureControl(key)
			captureControl.isEnabled = newValue

			Self.logger.log("Successfully \(messageBoolean)d \(messageSuffix)")
		} catch {
			Self.logger.log(error: error, "Failed to \(messageBoolean) \(messageSuffix)")
		}
	}
}
