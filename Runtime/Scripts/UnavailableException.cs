using System;

namespace CameraControl {
	//[System.Serializable]
	internal sealed class UnavailableException : Exception {
		public UnavailableException() : base("CameraControl is only available on iOS.") { }
	}
}