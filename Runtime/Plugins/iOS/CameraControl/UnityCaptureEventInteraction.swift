import AVKit
import Foundation

// MARK: -

@objc
public final class UnityCaptureEventInteraction: NSObject {
	@objc
	public static let shared: UnityCaptureEventInteraction = UnityCaptureEventInteraction()

	private var keyGenerator: SimpleKeyGenerator<CaptureEventInteractionKey, CaptureEventInteractionKey>

	private var storage: [CaptureEventInteractionKey: AVCaptureEventInteraction]

	private override init() {
		keyGenerator = SimpleKeyGenerator(in: CaptureEventInteractionKey.min ... CaptureEventInteractionKey.max - 1)
		storage = [:]
		super.init()
	}
}

// MARK: - Utility

private extension UnityCaptureEventInteraction {
	static let logger: LogCategory = .captureEventInteraction
}

// MARK: -

public extension UnityCaptureEventInteraction {
	typealias EventInteractionCallback = (CaptureEventInteractionKey, UInt64) -> Void

	private func createInteraction(body: (CaptureEventInteractionKey) -> AVCaptureEventInteraction) -> CaptureEventInteractionKey {
		lazy var messageInfix: String = "capture event interation"

		do {
			let key = try keyGenerator.generate(excluding: storage.keys)
			let interaction: AVCaptureEventInteraction = body(key)
			storage[key] = interaction
			UnityGetGLView().addInteraction(interaction)
			Self.logger.log("Successfully created \(messageInfix) with key \(key).")
			return key
		} catch {
			Self.logger.log(error: error, "Failed to create \(messageInfix).")
			return CaptureEventInteractionKey.max
		}
	}

	@objc
	func createInteractionCombined(handler: @escaping EventInteractionCallback) -> CaptureEventInteractionKey {
		createInteraction { key in 
			AVCaptureEventInteraction(
				handler: { event in
					handler(key, UInt64(event.phase.rawValue))
				}
			)
		}
	}

	@objc
	func createInteractionSeparated(primary: @escaping EventInteractionCallback, secondary: @escaping EventInteractionCallback) -> CaptureEventInteractionKey {
		createInteraction { key in 
			AVCaptureEventInteraction(
				primary: { event in
					secondary(key, UInt64(event.phase.rawValue))
				},
				secondary: { event in
					secondary(key, UInt64(event.phase.rawValue))
				}
			)
		}
	}

	@objc
	func destroyInteraction(_ key: CaptureEventInteractionKey) -> Bool {
		lazy var messageSuffix: String = "capture event interaction with key \(key)."

		guard let interaction = storage.removeValue(forKey: key) else {
			Self.logger.log("Failed to remove \(messageSuffix)")
			return false
		}

		UnityGetGLView().removeInteraction(interaction)
		Self.logger.log("Successfully removed \(messageSuffix)")

		return true
	}

	@objc
	func containsInteraction(_ key: CaptureEventInteractionKey) -> Bool {
		storage.keys.contains(key)
	}

	// MARK: - Is Enabled

	@objc
	func getIsEnabled(_ key: CaptureEventInteractionKey) -> Bool {
		storage[key]?.isEnabled ?? false
	}

	@objc
	func setIsEnabled(_ key: CaptureEventInteractionKey, newValue: Bool) {
		storage[key]?.isEnabled = newValue
	}
}
