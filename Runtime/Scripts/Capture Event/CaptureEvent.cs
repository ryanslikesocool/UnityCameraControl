namespace CameraControl {
	/// <summary>
	/// An object that describes a user interaction with a system hardware button.
	///
	/// 	<para>
	/// 	Inspect a capture event’s <see cref="phase"/>  to determine whether the event begins, ends, or is in a canceled state.
	/// 	</para>
	/// </summary>
	public readonly struct CaptureEvent {
		/// <summary>
		/// The current phase of a capture event.
		/// </summary>
		public readonly CaptureEventPhase phase;

		internal CaptureEvent(ulong phase) {
			this.phase = (CaptureEventPhase)phase;
		}
	}
}
