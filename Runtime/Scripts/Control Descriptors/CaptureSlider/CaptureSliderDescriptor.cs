using System;
using UnityEngine;

namespace CameraControl {
	[Serializable]
	public struct CaptureSliderDescriptor : ICaptureControlDescriptor<CaptureSlider> {
		public string localizedTitle;
		public string symbolName;

		public string accessibilityIdentifier;
		public string localizedValueFormat;

		// TODO: Add custom property drawer to make this bit pretty
		[SerializeField] internal CaptureSliderDescriptorMode mode;
		public float lowerBound;
		public float upperBound;
		public float step;
		public float[] values;

		// MARK: - Lifecycle

		public CaptureSliderDescriptor(string localizedTitle, string symbolName, float lowerBound, float upperBound) {
			this.localizedTitle = localizedTitle;
			this.symbolName = symbolName;

			this.accessibilityIdentifier = default;
			this.localizedValueFormat = default;

			this.mode = CaptureSliderDescriptorMode.Range;
			this.lowerBound = lowerBound;
			this.upperBound = upperBound;
			this.step = default;
			this.values = default;
		}

		public CaptureSliderDescriptor(string localizedTitle, string symbolName, float lowerBound, float upperBound, float step) {
			this.localizedTitle = localizedTitle;
			this.symbolName = symbolName;

			this.accessibilityIdentifier = default;
			this.localizedValueFormat = default;

			this.mode = CaptureSliderDescriptorMode.RangeAndStep;
			this.lowerBound = lowerBound;
			this.upperBound = upperBound;
			this.step = step;
			this.values = default;
		}

		public CaptureSliderDescriptor(string localizedTitle, string symbolName, float[] values) {
			this.localizedTitle = localizedTitle;
			this.symbolName = symbolName;

			this.accessibilityIdentifier = default;
			this.localizedValueFormat = default;

			this.mode = CaptureSliderDescriptorMode.Values;
			this.lowerBound = default;
			this.upperBound = default;
			this.step = default;
			this.values = values;
		}
	}
}