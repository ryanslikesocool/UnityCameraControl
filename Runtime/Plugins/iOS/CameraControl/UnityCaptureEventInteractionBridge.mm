#import <UnityFramework/UnityFramework-Swift.h>
#import "UnityInterface.h"

extern "C" {
	unsigned short cCaptureEventInteraction_CreateCombined(void (*handler)(unsigned short, unsigned long)) {
		return [[UnityCaptureEventInteraction shared] createInteractionCombinedWithHandler:^(uint16_t key, uint64_t phase) {
			handler(key, phase);
		}];
	}

	unsigned short cCaptureEventInteraction_CreateSeparated(
		void (*primary)(unsigned short, unsigned long), 
		void (*secondary)(unsigned short, unsigned long)
	) {
		return [[UnityCaptureEventInteraction shared] createInteractionSeparatedWithPrimary:^(uint16_t key, uint64_t phase) {
			primary(key, phase);
		} secondary:^(uint16_t key, uint64_t phase) {
			secondary(key, phase);
		}];
	}

	bool cCaptureEventInteraction_Destroy(unsigned short key) {
		return [[UnityCaptureEventInteraction shared] destroyInteraction :key];
	}

	bool cCaptureEventInteraction_Contains(unsigned short key) {
		return [[UnityCaptureEventInteraction shared] containsInteraction :key];
	}

	bool cCaptureEventInteraction_GetIsEnabled(unsigned short key) {
		return [[UnityCaptureEventInteraction shared] getIsEnabled: key];
	}

	void cCaptureEventInteraction_SetIsEnabled(unsigned short key, bool newValue) {
		[[UnityCaptureEventInteraction shared] setIsEnabled: key newValue:newValue];
	}
}
