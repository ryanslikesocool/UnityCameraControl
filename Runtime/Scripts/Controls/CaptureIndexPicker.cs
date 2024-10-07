/*
--->
SOON

using System.Collections;
using System.Collections.Generic;
#if UNITY_IOS && !UNITY_EDITOR
using System.Runtime.InteropServices;
#endif

namespace CameraControl {
	/// <summary>
	/// A control for selecting from a set of mutually exclusive values by index.
	/// 	<para>
	/// 	Index pickers are appropriate for controls that provide an indexed container of values.
	/// 	</para>
	/// </summary>
	/// <remarks>
	/// This class provides C# bindings to <see href="https://developer.apple.com/documentation/avfoundation/avcaptureindexpicker">AVCaptureIndexPicker</see>.
	/// </remarks>
	public class CaptureIndexPicker : CaptureControl {
		/// <summary>
		/// A localized title that describes the control’s action.
		/// </summary>
		public readonly string localizedTitle;

		/// <summary>
		/// The name of the SF Symbol that represents this control.
		/// </summary>
		public readonly string symbolName;

		/// <summary>
		/// The currently selected index.
		/// </summary>
		public int selectedIndex;

		/// <summary>
		/// The number of index values the control provides.
		/// </summary>
		public int numberOfIndexes;

		/// <summary>
		/// A string identifier for this control.
		/// </summary>
		public string accessibilityIdentifier;

		/// <summary>
		/// The titles to present for each index.
		/// </summary>
		public string[] localizedIndexTitles;

		// MARK: - Constructors

		private CaptureIndexPicker(ushort key, string localizedTitle, string symbolName) : base(key) {
			this.localizedTitle = localizedTitle;
			this.symbolName = symbolName;
		}
	}
}
*/