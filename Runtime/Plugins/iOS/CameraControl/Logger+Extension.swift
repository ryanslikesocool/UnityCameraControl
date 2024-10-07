import OSLog

extension Logger {
	init(category: String) { 
		self.init(subsystem: Self.unityCameraControlSubsystem, category: category)
	}

	init(category: Any.Type) { 
		self.init(category: String(describing: category))
	}
}

// MARK: - Constants

extension Logger { 
	private static let unityCameraControlSubsystem: String = "com.DevelopedWithLove.UnityCameraControl"
}
