#import "UnityInterface.h"
#import <UnityFramework/UnityFramework-Swift.h>

extern "C" {
	/// Should never need this, since log flags are not set in native code.
	//void cLog_GetLogFlags() {
	//	return [Debug getLogFlags];
	//}

	void cLog_SetLogFlags(unsigned char flags) {
		[Debug setLogFlags :flags];
	}
}
