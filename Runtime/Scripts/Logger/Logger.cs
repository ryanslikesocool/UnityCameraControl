#if UNITY_IOS && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

namespace CameraControl {
	public static class Logger {
		private static LogFlags logFlags = LogFlags.None;

		public static LogFlags LogFlags {
			get => logFlags;
			set {
				logFlags = value;
#if UNITY_IOS && !UNITY_EDITOR
				cLog_SetLogFlags((byte)value);
#endif
			}
		}

		// MARK: - Native

#if UNITY_IOS && !UNITY_EDITOR
		/// Should never need this, since log flags are not set in native code.
		//[DllImport("__Internal")]
		//private static extern byte cLog_GetLogFlags();

		[DllImport("__Internal")]
		private static extern void cLog_SetLogFlags(byte newValue);
#endif
	}
}