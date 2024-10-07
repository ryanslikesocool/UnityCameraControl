using UnityEngine;

namespace CameraControl {
	/// <summary>
	/// Constants that indicate how <see cref="CaptureSliderDescriptor"/> should be displayed in the editor.
	/// </summary>
	internal enum CaptureSliderDescriptorMode : byte {
		Range,
		[InspectorName("Range and Step")] RangeAndStep,
		Values,
	}
}