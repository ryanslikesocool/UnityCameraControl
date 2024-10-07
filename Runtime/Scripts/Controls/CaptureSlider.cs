using System;
using System.Collections;
using System.Collections.Generic;
#if UNITY_IOS && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

namespace CameraControl {
	/// <summary>
	/// A slider control that selects a value from a bounded range.
	/// 	<para>
	/// 	Sliders are appropriate for controls that provide a single float value.
	/// 	</para>
	/// </summary>
	/// <remarks>
	/// This class provides C# bindings to <see href="https://developer.apple.com/documentation/avfoundation/avcaptureslider">AVCaptureSlider</see>.
	/// </remarks>
	public class CaptureSlider : CaptureControl {
		public delegate void OnValueChagedDelegate(CaptureControl sender, float newValue);

		/// <summary>
		/// A localized title that describes the control’s action.
		/// </summary>
		public readonly string localizedTitle;

		/// <summary>
		/// The name of the SF Symbol that represents this control.
		/// </summary>
		public readonly string symbolName;

		/// <summary>
		/// The current value of the slider.
		/// </summary>
		public float Value {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCaptureSlider_GetValue(key);
			set => cCaptureSlider_SetValue(key, value);
#else
			get => 0.0f;
			set { }
#endif
		}

		/// <summary>
		/// Values in this array may receive unique visual representations or behaviors.
		/// </summary>
		public float[] ProminentValues {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCaptureSlider_GetProminentValues(key);
			set => cCaptureSlider_SetProminentValues(key, value);
#else
			get => null;
			set { }
#endif
		}

		/// <summary>
		/// A string identifier for the slider.
		/// </summary>
		public string AccessibilityIdentifier {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCaptureSlider_GetAccessibilityIdentifier(key);
			set => cCaptureSlider_SetAccessibilityIdentifier(key, value);
#else
			get => null;
			set { }
#endif
		}

		/// <summary>
		/// A localized string that defines the presentation of the slider’s value.
		/// 	<para>
		/// 	Specify a format string to modify the presentation of a slider’s value. The format string may only contain %@ and no other placeholders like %d, %s, and so on. Setting an Invalid format string results in the value’s default presentation.
		///  	</para>
		///		<para>
		/// 	Examples of valid format strings are:
		/// 		<list type="bullet">
		/// 			<item>“%@%” for “40%”</item>
		/// 			<item>“%@ fps” for “60 fps”</item>
		/// 			<item>“+ %@” for “+ 20”</item>
		/// 		</list>
		/// 	</para>
		/// </summary>
		public string LocalizedValueFormat {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCaptureSlider_GetLocalizedValueFormat(key);
			set => cCaptureSlider_SetLocalizedValueFormat(key, value);
#else
			get => null;
			set { }
#endif
		}

#pragma warning disable CS0067
		public event OnValueChagedDelegate OnValueChanged;
#pragma warning restore CS0067

		// MARK: - Lifecycle

		private CaptureSlider(ushort key, string localizedTitle, string symbolName) : base(key) {
			this.localizedTitle = localizedTitle;
			this.symbolName = symbolName;

#if UNITY_IOS && !UNITY_EDITOR
			cCaptureSlider_SetActionQueue(key, _NativeActionQueueDelegateCallback);
			instances.Add(key, this);
#endif
		}

#if UNITY_IOS && !UNITY_EDITOR
		public CaptureSlider(string localizedTitle, string symbolName, float lowerBound, float upperBound) : this(
			cCaptureSlider_InitWithRange(localizedTitle, symbolName, lowerBound, upperBound),
			localizedTitle,
			symbolName
		) { }
#else
		public CaptureSlider(string localizedTitle, string symbolName, float lowerBound, float upperBound) : this(0, localizedTitle, symbolName) {
			//throw new UnavailableException();
		}
#endif


#if UNITY_IOS && !UNITY_EDITOR
		public CaptureSlider(string localizedTitle, string symbolName, float lowerBound, float upperBound, float step) : this(
			cCaptureSlider_InitWithRangeStep(localizedTitle, symbolName, lowerBound, upperBound, step),
			localizedTitle,
			symbolName
		) { }
#else
		public CaptureSlider(string localizedTitle, string symbolName, float lowerBound, float upperBound, float step) : this(0, localizedTitle, symbolName) {
			//throw new UnavailableException();
		}
#endif

#if UNITY_IOS && !UNITY_EDITOR
		public CaptureSlider(string localizedTitle, string symbolName, float[] values) : this(
			cCaptureSlider_InitWithValues(localizedTitle, symbolName, values, values.Length),
			localizedTitle,
			symbolName
		) { }
#else
		public CaptureSlider(string localizedTitle, string symbolName, float[] values) : this(0, localizedTitle, symbolName) {
			//throw new UnavailableException();
		}
#endif

#if UNITY_IOS && !UNITY_EDITOR
		public CaptureSlider(in CaptureSliderDescriptor descriptor) : this(
			descriptor.mode switch {
				CaptureSliderDescriptorMode.Range => cCaptureSlider_InitWithRange(descriptor.localizedTitle, descriptor.symbolName, descriptor.lowerBound, descriptor.upperBound),
				CaptureSliderDescriptorMode.RangeAndStep => cCaptureSlider_InitWithRangeStep(descriptor.localizedTitle, descriptor.symbolName, descriptor.lowerBound, descriptor.upperBound, descriptor.step),
				CaptureSliderDescriptorMode.Values => cCaptureSlider_InitWithValues(descriptor.localizedTitle, descriptor.symbolName, descriptor.values, descriptor.values.Length),
				_ => throw new ArgumentOutOfRangeException()
			},
			descriptor.localizedTitle,
			descriptor.symbolName
		) { }
#else
		public CaptureSlider(in CaptureSliderDescriptor descriptor) : this(ushort.MaxValue, descriptor.localizedTitle, descriptor.symbolName) {
			//throw new UnavailableException();
		}
#endif

		// TODO: would using a finalizer be better than IDisposable?
		// ~CaptureSlider() { }

		public override void Dispose() {
#if UNITY_IOS && !UNITY_EDITOR
			instances.Remove(key);
#endif

			base.Dispose();
		}

		// MARK: - Native

#if UNITY_IOS && !UNITY_EDITOR
		private readonly static Dictionary<ushort, CaptureSlider> instances = new Dictionary<ushort, CaptureSlider>();

		private delegate void _NativeActionQueueDelegate(ushort key, float value);

		// NOTE: methods marked with MonoPInvokeCallback must be static

		[MonoPInvokeCallback(typeof(_NativeActionQueueDelegate))]
		private static void _NativeActionQueueDelegateCallback(ushort key, float value) {
			if (instances.TryGetValue(key, out CaptureSlider captureControl)) {
				captureControl.OnValueChanged?.Invoke(captureControl, value);
			}
		}

		// MARK: Initialization

		[DllImport("__Internal")]
		private static extern ushort cCaptureSlider_InitWithRange(string localizedTitle, string symbolName, float lowerBound, float upperBound);

		[DllImport("__Internal")]
		private static extern ushort cCaptureSlider_InitWithRangeStep(string localizedTitle, string symbolName, float lowerBound, float upperBound, float step);

		[DllImport("__Internal")]
		private static extern ushort cCaptureSlider_InitWithValues(string localizedTitle, string symbolName, float[] values, int valueCount);

		// MARK: Delegate

		[DllImport("__Internal")]
		private static extern void cCaptureSlider_SetActionQueue(ushort key, _NativeActionQueueDelegate action);

		// MARK: Value

		[DllImport("__Internal")]
		private static extern float cCaptureSlider_GetValue(ushort key);

		[DllImport("__Internal")]
		private static extern void cCaptureSlider_SetValue(ushort key, float newValue);

		// MARK: Prominent Values

		[DllImport("__Internal")]
		private static extern float[] cCaptureSlider_GetProminentValues(ushort key);

		[DllImport("__Internal")]
		private static extern void cCaptureSlider_SetProminentValues(ushort key, float[] newValue);

		// MARK: Accessibility Identifier

		[DllImport("__Internal")]
		private static extern string cCaptureSlider_GetAccessibilityIdentifier(ushort key);

		[DllImport("__Internal")]
		private static extern void cCaptureSlider_SetAccessibilityIdentifier(ushort key, string newValue);

		// MARK: Localized Value Format

		[DllImport("__Internal")]
		private static extern string cCaptureSlider_GetLocalizedValueFormat(ushort key);

		[DllImport("__Internal")]
		private static extern void cCaptureSlider_SetLocalizedValueFormat(ushort key, string newValue);
#endif
	}
}
