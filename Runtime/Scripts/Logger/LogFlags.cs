using System;
using UnityEngine;

namespace CameraControl {
	[Flags]
	public enum LogFlags : byte {
		None = 0,

		Common = 1 << 0,
		CameraService = 1 << 1,
		CaptureControl = 1 << 2,
		CaptureEventInteraction = 1 << 3,

		[InspectorName("Everything")] All = Common | CameraService | CaptureControl | CaptureEventInteraction,
	}
}