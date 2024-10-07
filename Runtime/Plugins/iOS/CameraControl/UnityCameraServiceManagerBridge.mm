#import "UnityInterface.h"
#import <UnityFramework/UnityFramework-Swift.h>

extern "C" {
	// MARK: - Camera Service Management

	unsigned char cCameraService_CreateService() { 
		return [[UnityCameraServiceManager shared] createService];
	}

	bool cCameraService_DestroyService(unsigned char key) {
		return [[UnityCameraServiceManager shared] destroyService :key];
	}

	bool cCameraService_ContainsService(unsigned char key) {
		return [[UnityCameraServiceManager shared] containsService :key];
	}

	bool cCameraService_GetIsRunning(unsigned char key) { 
		return [[UnityCameraServiceManager shared] getIsRunning :key];
	}

	void cCameraService_SetIsRunning(unsigned char key, bool newValue) {
		[[UnityCameraServiceManager shared] setIsRunning :key newValue:newValue];
	}

	bool cCameraService_RemoveCaptureSessionControlsDelegate(unsigned char key) {
		return [[UnityCameraServiceManager shared] removeCaptureSessionControlsDelegate :key];
	}

	bool cCameraService_SetCaptureSessionControlsDelegate(
		unsigned char key, 
		void(*didBecomeActive)(unsigned char), 
		void(*didBecomeInactive)(unsigned char),
		void(*willEnterFullscreenAppearance)(unsigned char),
		void(*didEnterFullscreenAppearance)(unsigned char)
	) {
		return [[UnityCameraServiceManager shared] setCaptureSessionControlsDelegate :key didBecomeActive:^(unsigned char key) {
			didBecomeActive(key);
		} didBecomeInactive:^(unsigned char key) {
			didBecomeInactive(key);
		} willEnterFullscreenAppearance:^(unsigned char key) {
			willEnterFullscreenAppearance(key);
		} willExitFullscreenAppearance:^(unsigned char key) {
			didEnterFullscreenAppearance(key);
		}];
	}

	// MARK: - Capture Control Management

	bool cCameraService_SetControls(unsigned char cameraServiceKey, const unsigned short* captureControlKeys, int captureControlKeysCount) {
		NSMutableArray *captureControlKeysArray = [NSMutableArray arrayWithCapacity:captureControlKeysCount];
		for (int i = 0; i < captureControlKeysCount; i += 1) {
			[captureControlKeysArray addObject: [NSNumber numberWithFloat:captureControlKeys[i]]];
		}

		return [[UnityCameraServiceManager shared] setControls :cameraServiceKey :captureControlKeysArray];
	}

	bool cCameraService_AddControl(unsigned char cameraServiceKey, unsigned short captureControlKey) { 
		return [[UnityCameraServiceManager shared] addControl :cameraServiceKey :captureControlKey];
	}

	bool cCameraService_RemoveControl(unsigned char cameraServiceKey, unsigned short captureControlKey) {
		return [[UnityCameraServiceManager shared] removeControl :cameraServiceKey :captureControlKey];
	}

	bool cCameraService_RemoveAllControls(unsigned char cameraServiceKey) { 
		return [[UnityCameraServiceManager shared] removeAllControls :cameraServiceKey];
	}

	bool cCameraService_ContainsControl(unsigned char cameraServiceKey, unsigned short captureControlKey) {
		return [[UnityCameraServiceManager shared] containsControl :cameraServiceKey :captureControlKey];
	}

	long cCameraService_GetMaxControlsCount(unsigned char key) {
		return [[UnityCameraServiceManager shared] getMaxControlsCount :key];
	}

	bool cCameraService_GetSupportsControls(unsigned char key) {
		return [[UnityCameraServiceManager shared] getSupportsControls :key];
	}

	bool cCameraService_GetControlCount(unsigned char key) {
		return [[UnityCameraServiceManager shared] getControlCount :key];
	}
}
