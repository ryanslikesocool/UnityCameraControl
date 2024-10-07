using System;
#if UNITY_IOS && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

namespace CameraControl {
	/// <summary>
	/// An abstract base class for controls that interact with the camera system.
	/// 	<para>
	/// 	Capture controls provide the interface for interacting with the camera system from the Camera Control button on iPhone 16 devices.
	/// 	The framework provides several concrete subclasses of this class that allow apps to access built-in functionality and define custom controls.
	/// 	</para>
	/// </summary>
	/// <remarks>
	/// This class provides C# bindings to <see href="https://developer.apple.com/documentation/avfoundation/avcapturecontrol">AVCaptureControl</see>.
	/// </remarks>
	public abstract class CaptureControl : IDisposable {
		internal readonly ushort key;

		public bool IsEnabled {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCaptureControl_GetIsEnabled(key);
			set => cCaptureControl_SetIsEnabled(key, value);
#else
			get => false;
			set { }
#endif
		}

		private bool IsValid {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCaptureControl_ContainsControl(key);
#else
			get => false;
#endif
		}

		// MARK: - Lifecycle

		protected CaptureControl(ushort key) {
			this.key = key;
		}

		// TODO: would using a finalizer be better than IDisposable?
		// ~CaptureControl() { }

		public virtual void Dispose() {
#if UNITY_IOS && !UNITY_EDITOR
			cCaptureControl_DestroyControl(key);
#endif
		}

		// MARK: - Native

#if UNITY_IOS && !UNITY_EDITOR
		[DllImport("__Internal")]
		private static extern bool cCaptureControl_DestroyControl(ushort key);

		[DllImport("__Internal")]
		private static extern bool cCaptureControl_ContainsControl(ushort key);

		[DllImport("__Internal")]
		private static extern bool cCaptureControl_GetIsEnabled(ushort key);

		[DllImport("__Internal")]
		private static extern void cCaptureControl_SetIsEnabled(ushort key, bool newValue);
#endif
	}
}
