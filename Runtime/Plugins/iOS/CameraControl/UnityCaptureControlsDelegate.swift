import AVKit
import Foundation

//@nonobjc
final class UnityCaptureControlsDelegate: NSObject, AVCaptureSessionControlsDelegate { 
	typealias DelegateFunction = UnityCameraServiceManager.CaptureSessionControlsDelegateFunction

	let key: CameraServiceKey

	private let didBecomeActive: DelegateFunction
	private let didBecomeInactive: DelegateFunction
	private let willEnterFullscreenAppearance: DelegateFunction
	private let willExitFullscreenAppearance: DelegateFunction

	init(
		key: CameraServiceKey,
		didBecomeActive: @escaping DelegateFunction,
		didBecomeInactive: @escaping DelegateFunction,
		willEnterFullscreenAppearance: @escaping DelegateFunction,
		willExitFullscreenAppearance: @escaping DelegateFunction
	) { 
		self.key = key

		self.didBecomeActive = didBecomeActive
		self.didBecomeInactive = didBecomeInactive
		self.willEnterFullscreenAppearance = willEnterFullscreenAppearance
		self.willExitFullscreenAppearance = willExitFullscreenAppearance

		super.init()
	}

	public func sessionControlsDidBecomeActive(_ session: AVCaptureSession) {
		UnityCameraServiceManager.shared.assertSessionKey(session, matches: key)
		didBecomeActive(key)
	}

	public func sessionControlsDidBecomeInactive(_ session: AVCaptureSession) {
		UnityCameraServiceManager.shared.assertSessionKey(session, matches: key)
		didBecomeInactive(key)
	}

	public func sessionControlsWillEnterFullscreenAppearance(_ session: AVCaptureSession) {
		UnityCameraServiceManager.shared.assertSessionKey(session, matches: key)
		willEnterFullscreenAppearance(key)
	}

	public func sessionControlsWillExitFullscreenAppearance(_ session: AVCaptureSession) {
		UnityCameraServiceManager.shared.assertSessionKey(session, matches: key)
		willExitFullscreenAppearance(key)
	}
}