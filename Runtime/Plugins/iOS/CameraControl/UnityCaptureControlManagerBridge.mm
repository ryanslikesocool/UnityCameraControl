#import <UnityFramework/UnityFramework-Swift.h>
#import "UnityInterface.h"

extern "C" {
	char* cStringCopy(const char* string) {
		if (string == NULL) {
			return NULL;
		}

		size_t length = strlen(string) + 1;
		char* res = (char*) malloc(length);

		if (res != NULL) {
			memcpy(res, string, length);
		}

		return res;
	}

	// MARK: - Capture Control Management

	bool cCaptureControl_DestroyControl(unsigned short key) { 
		return [[UnityCaptureControlManager shared] destroyControl :key];
	}

	bool cCaptureControl_ContainsControl(unsigned short key) {
		return [[UnityCaptureControlManager shared] containsControl :key];
	}

	bool cCaptureControl_GetIsEnabled(unsigned short key) {
		return [[UnityCaptureControlManager shared] getIsEnabled :key];
	}

	void cCaptureControl_SetIsEnabled(unsigned short key, bool newValue) {
		[[UnityCaptureControlManager shared] setIsEnabled :key newValue:newValue];
	}

	// MARK: - AVCaptureSlider

	// MARK: Initialization

	unsigned short cCaptureSlider_InitWithRange(const char* localizedTitle, const char* symbolName, float lowerBound, float upperBound) {
		NSString *localizedTitleString = [NSString stringWithUTF8String:localizedTitle];
		NSString *symbolNameString = [NSString stringWithUTF8String:symbolName];

		return [[UnityCaptureControlManager shared] createCaptureSliderRange :localizedTitleString symbolName:symbolNameString lowerBound:lowerBound upperBound:upperBound];
	}

	unsigned short cCaptureSlider_InitWithRangeStep(const char* localizedTitle, const char* symbolName, float lowerBound, float upperBound, float step) {
		NSString *localizedTitleString = [NSString stringWithUTF8String:localizedTitle];
		NSString *symbolNameString = [NSString stringWithUTF8String:symbolName];

		return [[UnityCaptureControlManager shared] createCaptureSliderRangeStep :localizedTitleString symbolName:symbolNameString lowerBound:lowerBound upperBound:upperBound step:step];
	}

	unsigned short cCaptureSlider_InitWithValues(const char* localizedTitle, const char* symbolName, const float* values, int valueCount) {
		NSString *localizedTitleString = [NSString stringWithUTF8String:localizedTitle];
		NSString *symbolNameString = [NSString stringWithUTF8String:symbolName];
		NSMutableArray *valuesArray = [NSMutableArray arrayWithCapacity:valueCount];
		for (int i = 0; i < valueCount; i += 1) {
			[valuesArray addObject: [NSNumber numberWithFloat:values[i]]];
		}

		return [[UnityCaptureControlManager shared] createCaptureSliderValues :localizedTitleString symbolName:symbolNameString values:valuesArray];
	}

	// MARK: Delegate

	void cCaptureSlider_SetActionQueue(unsigned short key, void (*delegate)(unsigned short, float)) {
		[[UnityCaptureControlManager shared] setCaptureSliderActionQueue:key action:^(unsigned short key, float value) {
			delegate(key, value);
		}];
	}

	// MARK: Value

	float cCaptureSlider_GetValue(unsigned short key) {
		return [[UnityCaptureControlManager shared] getCaptureSliderValue :key];
	}

	void cCaptureSlider_SetValue(unsigned short key, float newValue) {
		[[UnityCaptureControlManager shared] setCaptureSliderValue :key newValue:newValue];
	}

	// MARK: Prominent Values

	float* cCaptureSlider_GetProminentValues(unsigned short key) {
		NSArray *prominentValues = [[UnityCaptureControlManager shared] getCaptureSliderProminentValues :key];
		unsigned long arrayCount = [prominentValues count];
		float *returnArray = (float *)malloc(sizeof(float) * arrayCount);
		for (int i = 0; i < arrayCount; i += 1) {
			returnArray[i] = [[prominentValues objectAtIndex:i] floatValue];
		}

		return returnArray;
	}

	void cCaptureSlider_SetProminentValues(unsigned short key, const float* values, int valueCount) {
		NSMutableArray *prominentValuesArray = [NSMutableArray arrayWithCapacity:valueCount];
		for (int i = 0; i < valueCount; i += 1) {
			[prominentValuesArray addObject: [NSNumber numberWithFloat:values[i]]];
		}

		[[UnityCaptureControlManager shared] setCaptureSliderProminentValues :key newValue:prominentValuesArray];
	}

	// MARK: Accessibility Identifier

	char* cCaptureSlider_GetAccessibilityIdentifier(unsigned short key) {
		NSString *returnString = [[UnityCaptureControlManager shared] getCaptureSliderAccessibilityIdentifier :key];
		// cStringCopy *should* handle NULL
		return cStringCopy([returnString UTF8String]);

		//if (returnString) {
		//	return cStringCopy([returnString UTF8String]);
		//} else {
		//	return NULL;
		//}
	}

	void cCaptureSlider_SetAccessibilityIdentifier(unsigned short key, const char* newValue) {
		NSString *newValueString = NULL;
		if (newValue) {
			newValueString = [NSString stringWithUTF8String:newValue];
		}

		[[UnityCaptureControlManager shared] setCaptureSliderAccessibilityIdentifier :key newValue:newValueString];
	}

	// MARK: Localized Value Format

	char* cCaptureSlider_GetLocalizedValueFormat(unsigned short key) {
		NSString *returnString = [[UnityCaptureControlManager shared] getCaptureSliderLocalizedValueFormat :key];
		// cStringCopy *should* handle NULL
		return cStringCopy([returnString UTF8String]);

		//if (returnString) {
		//	return cStringCopy([returnString UTF8String]);
		//} else {
		//	return NULL;
		//}
	}

	void cCaptureSlider_SetLocalizedValueFormat(ushort key, const char* newValue) {
		NSString *newValueString = NULL;
		if (newValue) {
			newValueString = [NSString stringWithUTF8String:newValue];
		}

		[[UnityCaptureControlManager shared] setCaptureSliderLocalizedValueFormat :key newValue:newValueString];
	}

	// MARK: - AVCaptureIndexPicker


}
