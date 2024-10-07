import OSLog

public enum LogCategory: UInt8 {
	case common
	case cameraService
	case captureControl
	case captureEventInteraction
}

// MARK: - 

extension LogCategory { 
	fileprivate static var enabledMask: LogCategory.Mask = []

	fileprivate static let commonLogger: Logger = Logger(category: "Common")
	private static let cameraServiceLogger: Logger = Logger(category: UnityCameraServiceManager.self)
	private static let captureControlLogger: Logger = Logger(category: UnityCaptureControlManager.self)
	private static let captureEventInteractionLogger: Logger = Logger(category: UnityCaptureEventInteraction.self)
}

// MARK: - 

extension LogCategory { 
	private var mask: Mask { 
		Mask(self)
	}

	private var isEnabled: Bool {
		get {  Self.enabledMask.contains(mask) }
		set { 
			if newValue {
				Self.enabledMask.insert(mask)
			} else {
				Self.enabledMask.remove(mask)
			}
		}
	}

	private var logger: Logger { 
		switch self {
			case .common: Self.commonLogger
			case .cameraService: Self.cameraServiceLogger
			case .captureControl: Self.captureControlLogger
			case .captureEventInteraction: Self.captureEventInteractionLogger
		}
	}

	func log(
		level: OSLogType = .debug,
		function: StaticString = #function,
		_ message: @autoclosure @escaping () -> String
	) { 
		guard isEnabled else {
			return
		}

		//logger.log(level: level, """
		//\(function)
		//\(message())
		//""")
		logger.log(level: level, "\(message())")
	}

	func log(
		level: OSLogType = .error,
		function: StaticString = #function,
		error: any Error,
		_ message: @autoclosure @escaping () -> String? = nil
	) {
		log(level: level, function: function, {
			if let message = message() {
				"""
				\(message)
				- \(error)
				"""
			} else {
				"- \(error)"
			}
		}())
	}
}

// MARK: - Obj-C

public extension Debug {
	/// Should never need this, since log flags are not set in native code.
	//@objc
	//static func getLogFlags() -> LogCategory.Mask.RawValue { 
	//	LogCategory.enabledMask.rawValue
	//}

	@objc
	static func setLogFlags(_ newValue: LogCategory.Mask.RawValue) {
		LogCategory.enabledMask = LogCategory.Mask(rawValue: newValue)

		LogCategory.commonLogger.info("Set log flags \(newValue).")
	}
}
