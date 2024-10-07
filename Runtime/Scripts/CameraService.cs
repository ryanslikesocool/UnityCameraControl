using System;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_IOS && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

namespace CameraControl {
	public sealed class CameraService : IDisposable {
		public delegate void DidBecomeActiveDelegate(CameraService sender);
		public delegate void DidBecomeInactiveDelegate(CameraService sender);
		public delegate void WillEnterFullscreenAppearanceDelegate(CameraService sender);
		public delegate void WillExitFullscreenAppearanceDelegate(CameraService sender);

		private readonly byte key;

		private Dictionary<ushort, CaptureControl> controls;

		public bool IsRunning {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCameraService_GetIsRunning(key);
			set => cCameraService_SetIsRunning(key, value);
#else
			get => false;
			set { }
#endif
		}

		public int MaxControlsCount {
#if UNITY_IOS && !UNITY_EDITOR
			get => (int)cCameraService_GetMaxControlsCount(key);
#else
			get => 0;
#endif
		}

		public bool SupportsControls {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCameraService_GetSupportsControls(key);
#else
			get => false;
#endif
		}

		public int ControlCount {
#if UNITY_IOS && !UNITY_EDITOR
			get => (int)cCameraService_GetControlCount(key);
#else
			get => 0;
#endif
		}

		private bool IsValid {
#if UNITY_IOS && !UNITY_EDITOR
			get => cCameraService_ContainsService(key);
#else
			get => false;
#endif
		}

#pragma warning disable CS0067
		public event DidBecomeActiveDelegate DidBecomeActive;
		public event DidBecomeInactiveDelegate DidBecomeInactive;
		public event WillEnterFullscreenAppearanceDelegate WillEnterFullscreenAppearance;
		public event WillExitFullscreenAppearanceDelegate WillExitFullscreenAppearance;
#pragma warning restore CS0067

		// MARK: - Lifecycle

		private CameraService(byte key) {
			this.key = key;
			controls = new Dictionary<ushort, CaptureControl>();

#if UNITY_IOS && !UNITY_EDITOR
			cCameraService_SetCaptureSessionControlsDelegate(
				key,
				_NativeCaptureSessionControlsDelegateDidBecomeActiveCallback,
				_NativeCaptureSessionControlsDelegateDidBecomeInactiveCallback,
				_NativeCaptureSessionControlsDelegateWillEnterFullscreenAppearanceCallback,
				_NativeCaptureSessionControlsDelegateWillExitFullscreenAppearanceCallback
			);
			instances.Add(key, this);
#endif
		}

#if UNITY_IOS && !UNITY_EDITOR
		public CameraService() : this(
			cCameraService_CreateService()
		) { }
#else
		public CameraService() : this(byte.MaxValue) {
			//throw new UnavailableException();
		}
#endif

		// TODO: would using a finalizer be better than IDisposable?
		// ~CameraService() { }

		public void Dispose() {
			controls.Clear();

#if UNITY_IOS && !UNITY_EDITOR
			instances.Remove(key);
			cCameraService_DestroyService(key);
			cCameraService_RemoveCaptureSessionControlsDelegate(key);
#endif
		}

		// MARK: - Control

		//private bool AssertControlPresent(CaptureControl control)
		//	=> this.controls[control.key] == control;

		public bool SetControls(CaptureControl[] controls) {
			Debug.AssertFormat(controls.Length > 0, $"The provided capture control key array was empty.  Use `{nameof(RemoveAllControls)}` if the intent was to remove all controls.");

			bool result;

#if UNITY_IOS && !UNITY_EDITOR
			int captureControlKeysCount = controls.Length;
			ushort[] captureControlKeys = new ushort[captureControlKeysCount];
			for (int i = 0; i < captureControlKeysCount; i++) {
				captureControlKeys[i] = controls[i].key;
			}

			result = cCameraService_SetControls(key, captureControlKeys, captureControlKeysCount);
#else
			result = true;
#endif

			this.controls.Clear();
			for (int i = 0; i < controls.Length; i++) {
				this.controls.Add(controls[i].key, controls[i]);
			}

			return result;
		}

		public bool AddControl(CaptureControl control) {
#if UNITY_IOS && !UNITY_EDITOR
			bool externalResult = cCameraService_AddControl(key, control.key);
			if (externalResult) {
				controls.Add(control.key, control);
			}
			return externalResult;
#else
			return controls.TryAdd(control.key, control);
#endif
		}

		/// <returns><see langword="true"/> if the given capture control was present and successfully removed; <see langword="false"/> otherwise.</returns>
		public bool RemoveControl(CaptureControl control) {
#if UNITY_IOS && !UNITY_EDITOR
			bool externalResult = cCameraService_RemoveControl(key, control.key);
			bool internalResult = false;
			if (externalResult) {
				internalResult = controls.Remove(control.key);
			}
			return internalResult && externalResult;
#else
			return controls.Remove(control.key);
#endif
		}

		/// <returns><see langword="true"/> if the camera service contains the given capture control; <see langword="false"/> otherwise.</returns>
		public bool ContainsControl(CaptureControl control) {
			bool internalResult = controls[control.key] == control;
#if UNITY_IOS && !UNITY_EDITOR
			bool externalResult = cCameraService_ContainsControl(key, control.key);
			return internalResult && externalResult;
#else
			return internalResult;
#endif
		}

		/// <summary>
		/// Remove all controls in the camera service.
		/// </summary>
		public bool RemoveAllControls() {
#if UNITY_IOS && !UNITY_EDITOR
			bool externalResult = cCameraService_RemoveAllControls(key);
			if (externalResult) {
				controls.Clear();
			}
			return externalResult;
#else
			controls.Clear();
			return true;
#endif
		}

		// MARK: - Native

#if UNITY_IOS && !UNITY_EDITOR
		private static Dictionary<byte, CameraService> instances = new Dictionary<byte, CameraService>();

		private delegate void _NativeCaptureSessionControlsDelegate(byte key);

		// NOTE: methods marked with MonoPInvokeCallback must be static

		[MonoPInvokeCallback(typeof(_NativeCaptureSessionControlsDelegate))]
		private static void _NativeCaptureSessionControlsDelegateDidBecomeActiveCallback(byte key) {
			if (instances.TryGetValue(key, out CameraService cameraService)) {
				cameraService.DidBecomeActive?.Invoke(cameraService);
			}
		}

		[MonoPInvokeCallback(typeof(_NativeCaptureSessionControlsDelegate))]
		private static void _NativeCaptureSessionControlsDelegateDidBecomeInactiveCallback(byte key) {
			if (instances.TryGetValue(key, out CameraService cameraService)) {
				cameraService.DidBecomeInactive?.Invoke(cameraService);
			}
		}

		[MonoPInvokeCallback(typeof(_NativeCaptureSessionControlsDelegate))]
		private static void _NativeCaptureSessionControlsDelegateWillEnterFullscreenAppearanceCallback(byte key) {
			if (instances.TryGetValue(key, out CameraService cameraService)) {
				cameraService.WillEnterFullscreenAppearance?.Invoke(cameraService);
			}
		}

		[MonoPInvokeCallback(typeof(_NativeCaptureSessionControlsDelegate))]
		private static void _NativeCaptureSessionControlsDelegateWillExitFullscreenAppearanceCallback(byte key) {
			if (instances.TryGetValue(key, out CameraService cameraService)) {
				cameraService.WillExitFullscreenAppearance?.Invoke(cameraService);
			}
		}

		// MARK: Camera Service Management

		[DllImport("__Internal")]
		private static extern byte cCameraService_CreateService();

		[DllImport("__Internal")]
		private static extern void cCameraService_DestroyService(byte key);

		[DllImport("__Internal")]
		private static extern bool cCameraService_ContainsService(byte key);

		[DllImport("__Internal")]
		private static extern bool cCameraService_GetIsRunning(byte key);

		[DllImport("__Internal")]
		private static extern void cCameraService_SetIsRunning(byte key, bool newValue);

		// MARK: Delegate

		[DllImport("__Internal")]
		private static extern bool cCameraService_RemoveCaptureSessionControlsDelegate(byte key);

		[DllImport("__Internal")]
		private static extern bool cCameraService_SetCaptureSessionControlsDelegate(
			byte key,
			_NativeCaptureSessionControlsDelegate didBecomeActive,
			_NativeCaptureSessionControlsDelegate didBecomeInactive,
			_NativeCaptureSessionControlsDelegate willEnterFullscreenAppearance,
			_NativeCaptureSessionControlsDelegate willExitFullscreenAppearance
		);

		// MARK: Capture Control Mangement

		[DllImport("__Internal")]
		private static extern bool cCameraService_SetControls(byte cameraServiceKey, ushort[] captureControlKeys, int captureControlKeysCount);

		[DllImport("__Internal")]
		private static extern bool cCameraService_AddControl(byte cameraServiceKey, ushort captureControlKey);

		[DllImport("__Internal")]
		private static extern bool cCameraService_RemoveControl(byte cameraServiceKey, ushort captureControlKey);

		[DllImport("__Internal")]
		private static extern bool cCameraService_RemoveAllControls(byte cameraServiceKey);

		[DllImport("__Internal")]
		private static extern bool cCameraService_ContainsControl(byte cameraServiceKey, ushort captureControlKey);

		[DllImport("__Internal")]
		private static extern bool cCameraService_GetControlIsEnabled(byte cameraServiceKey, ushort captureControlKey);

		[DllImport("__Internal")]
		private static extern void cCameraService_SetControlIsEnabled(byte cameraServiceKey, ushort captureControlKey, bool newValue);

		[DllImport("__Internal")]
		private static extern long cCameraService_GetMaxControlsCount(byte key);

		[DllImport("__Internal")]
		private static extern bool cCameraService_GetSupportsControls(byte key);

		[DllImport("__Internal")]
		private static extern long cCameraService_GetControlCount(byte key);
#endif
	}
}