namespace CameraControl {
	/// <summary>
	/// Constants that indicate the phase of a system capture event.
	/// </summary>
	public enum CaptureEventPhase : ulong {
		/// <summary>
		/// A phase that indicates the beginning of a capture event.
		///
		/// 	<para>
		/// 	This phase corresponds to a user pressing down on a hardware button.
		/// 	</para>
		/// </summary>
		Began,

		/// <summary>
		/// A phase that indicates the end of a capture event.
		///
		/// 	<para>
		/// 	This phase corresponds to a user pressing up on a hardware button.
		/// 	</para>
		/// </summary>
		Ended,

		/// <summary>
		/// A phase that indicates the cancellation of a capture event.
		/// </summary>
		Cancelled
	}
}
