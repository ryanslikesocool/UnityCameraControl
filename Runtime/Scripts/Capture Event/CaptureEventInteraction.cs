using UnityEngine;
using System;
using System.Collections.Generic;
#if UNITY_IOS && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

namespace CameraControl {
	/// <summary>
	/// An object that registers handlers to respond to capture events from system hardware buttons.
	///
	/// 	<para>
	/// 	The system Camera app allows people to perform capture functions by pressing hardware buttons on their iOS device.
	/// 	You can add similar functionality to your app by using this type to register handlers that respond to interactions from device hardware.
	/// 	</para>
	/// 	<para>
	/// 	You can only use this API for capture use cases. The system sends capture events only to apps that actively use the camera.
	/// 	Backgrounded capture apps, and apps not performing capture, don’t receive events.
	/// 	</para>
	/// 	<para>
	/// 	Adopting this API overrides default hardware button behavior, so apps must always respond appropriately to any events received.
	/// 	Failing to handle events results in a nonfunctional button that provides a poor user experience.
	/// 	If your app is temporarily unable to handle events, disable the interaction by setting its <see cref="IsEnabled"/> property to <see langword="false"/>, which restores the system button behavior.
	/// 	</para>
	/// </summary>
	public sealed class CaptureEventInteraction : IDisposable {
		private readonly ushort key;

		public delegate void CaptureEventAction(CaptureEvent @event);

		/// <summary>
		/// A Boolean value that indicates whether this capture event interaction is in an enabled state.
		/// </summary>
		public bool IsEnabled {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCaptureEventInteraction_GetIsEnabled(key);
			set => cCaptureEventInteraction_SetIsEnabled(key, value);
#else
			get => false;
			set { }
#endif
		}

		private bool IsValid {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCaptureEventInteraction_Contains(key);
#else
			get => false;
#endif
		}

		private readonly CaptureEventAction combined;
		private readonly CaptureEventAction primary;
		private readonly CaptureEventAction secondary;

		// MARK: - Lifecycle

		private CaptureEventInteraction(ushort key, CaptureEventAction combined, CaptureEventAction primary, CaptureEventAction secondary) {
			this.key = key;
			this.combined = combined;
			this.primary = primary;
			this.secondary = secondary;

#if UNITY_IOS && !UNITY_EDITOR
			instances.Add(key, this);
#endif
		}

		/// <summary>
		/// Creates a capture event interaction with a handler that responds to presses of the volume up or volume down button.
		/// </summary>
		/// <param name="handler">An event handler the system calls when a user presses the volume up or down buttons on their iOS device.</param>
#if UNITY_IOS && !UNITY_EDITOR
		public CaptureEventInteraction(CaptureEventAction handler) : this(
			cCaptureEventInteraction_CreateCombined(_NativeCombinedDelegateCallback),
			handler, null, null
		) {
			Debug.Assert(handler != null);
		}
#else
		public CaptureEventInteraction(CaptureEventAction handler) : this(0, handler, null, null) {
			Debug.Assert(handler != null);
			//throw new UnavailableException();
		}
#endif

		/// <summary>
		/// Creates a capture event interaction with handlers that respond independently to presses of the volume up and volume down buttons.
		/// </summary>
		/// <param name="primary">A callback the system invokes when a person presses the volume up button on their iOS device.</param>
		/// <param name="secondary">A callback the system invokes when a person presses the volume down button on their iOS device.</param>
#if UNITY_IOS && !UNITY_EDITOR
		public CaptureEventInteraction(CaptureEventAction primary, CaptureEventAction secondary) : this(
			cCaptureEventInteraction_CreateSeparated(_NativePrimaryDelegateCallback, _NativeSecondaryDelegateCallback),
			null, primary, secondary
		) {
			Debug.Assert(primary != null);
			Debug.Assert(secondary != null);
		}
#else
		public CaptureEventInteraction(CaptureEventAction primary, CaptureEventAction secondary) : this(0, null, primary, secondary) {
			Debug.Assert(primary != null);
			Debug.Assert(secondary != null);
			//throw new UnavailableException();
		}
#endif


		// TODO: would using a finalizer be better than IDisposable?
		// ~CaptureEventInteraction() { }

		public void Dispose() {
#if UNITY_IOS && !UNITY_EDITOR
			cCaptureEventInteraction_Destroy(key);
			instances.Remove(key);
#endif
		}

		// MARK: - Native

#if UNITY_IOS && !UNITY_EDITOR
		private static Dictionary<ushort, CaptureEventInteraction> instances = new Dictionary<ushort, CaptureEventInteraction>();

		private delegate void _NativeDelegate(ushort key, ulong phase);

		// NOTE: methods marked with MonoPInvokeCallback must be static

		[MonoPInvokeCallback(typeof(_NativeDelegate))]
		private static void _NativeCombinedDelegateCallback(ushort key, ulong phase) {
			if (instances.TryGetValue(key, out CaptureEventInteraction instance)) {
				CaptureEvent captureEvent = new CaptureEvent(phase);
				instance.combined(captureEvent);
			}
		}

		[MonoPInvokeCallback(typeof(_NativeDelegate))]
		private static void _NativePrimaryDelegateCallback(ushort key, ulong phase) {
			if (instances.TryGetValue(key, out CaptureEventInteraction instance)) {
				CaptureEvent captureEvent = new CaptureEvent(phase);
				instance.primary(captureEvent);
			}
		}

		[MonoPInvokeCallback(typeof(_NativeDelegate))]
		private static void _NativeSecondaryDelegateCallback(ushort key, ulong phase) {
			if (instances.TryGetValue(key, out CaptureEventInteraction instance)) {
				CaptureEvent captureEvent = new CaptureEvent(phase);
				instance.secondary(captureEvent);
			}
		}

		// MARK: External

		[DllImport("__Internal")]
		private static extern ushort cCaptureEventInteraction_CreateCombined(_NativeDelegate handler);

		[DllImport("__Internal")]
		private static extern ushort cCaptureEventInteraction_CreateSeparated(_NativeDelegate primary, _NativeDelegate secondary);

		[DllImport("__Internal")]
		private static extern bool cCaptureEventInteraction_Destroy(ushort key);

		[DllImport("__Internal")]
		private static extern bool cCaptureEventInteraction_Contains(ushort key);

		[DllImport("__Internal")]
		private static extern bool cCaptureEventInteraction_GetIsEnabled(ushort key);

		[DllImport("__Internal")]
		private static extern void cCaptureEventInteraction_SetIsEnabled(ushort key, bool newValue);
#endif
	}
}
