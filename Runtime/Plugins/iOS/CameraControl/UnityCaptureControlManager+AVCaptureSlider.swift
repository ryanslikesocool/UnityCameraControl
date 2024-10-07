import AVKit
import Foundation

public extension UnityCaptureControlManager { 
	// MARK: - Initialization

	@objc
	func createCaptureSliderRange(_ localizedTitle: String, symbolName: String, lowerBound: Float, upperBound: Float) -> Key { 
		let control = AVCaptureSlider(localizedTitle, symbolName: symbolName, in: lowerBound ... upperBound)
		return createControl(control)
	}

	@objc
	func createCaptureSliderRangeStep(_ localizedTitle: String, symbolName: String, lowerBound: Float, upperBound: Float, step: Float) -> Key {
		let control = AVCaptureSlider(localizedTitle, symbolName: symbolName, in: lowerBound ... upperBound, step: step)
		return createControl(control)
	}

	@objc
	func createCaptureSliderValues(_ localizedTitle: String, symbolName: String, values: [Float]) -> Key {
		let control = AVCaptureSlider(localizedTitle, symbolName: symbolName, values: values)
		return createControl(control)
	}

	// MARK: - Delegate

	@objc
	func setCaptureSliderActionQueue(_ key: Key, action delegate: @escaping (Key, Float) -> Void) {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.setActionQueue(.main) { value in
				delegate(key, value)
			}
		}
	}


	// MARK: - Value

	@objc
	func getCaptureSliderValue(_ key: Key) -> Float {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.value
		} ?? Float.zero
	}

	@objc
	func setCaptureSliderValue(_ key: Key, newValue: Float) {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.value = newValue
		}
	}

	// MARK: - Prominent Values

	@objc
	func getCaptureSliderProminentValues(_ key: Key) -> [Float] {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.prominentValues
		} ?? []
	}

	@objc
	func setCaptureSliderProminentValues(_ key: Key, newValue: [Float]) {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.prominentValues = newValue
		}
	}

	// MARK: - Accessibility Identifier

	@objc
	func getCaptureSliderAccessibilityIdentifier(_ key: Key) -> String? {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.accessibilityIdentifier
		} ?? nil
	}

	@objc
	func setCaptureSliderAccessibilityIdentifier(_ key: Key, newValue: String?) {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.accessibilityIdentifier = newValue
		}
	}

	// MARK: - Localized Value Format

	@objc
	func getCaptureSliderLocalizedValueFormat(_ key: Key) -> String? {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.localizedValueFormat
		} ?? nil
	}

	@objc
	func setCaptureSliderLocalizedValueFormat(_ key: Key, newValue: String?) {
		tryWithCaptureControl(key, as: AVCaptureSlider.self) { control in
			control.localizedValueFormat = newValue
		}
	}
}
