public extension LogCategory {
	struct Mask: OptionSet {
		public let rawValue: LogCategory.RawValue

		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}

		public init(_ category: LogCategory) {
			self.init(rawValue: 1 << category.rawValue)
		}
	}
}

// MARK: - Constants

public extension LogCategory.Mask {
	static let common: Self = Self(.common)
	static let cameraService: Self = Self(.cameraService)
	static let captureControl: Self = Self(.captureControl)
	static let captureEventInteraction: Self = Self(.captureEventInteraction)

	static let all: Self = [.common, .cameraService, .captureControl, .captureEventInteraction]
}
