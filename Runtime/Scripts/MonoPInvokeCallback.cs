using System;

namespace CameraControl {
	// MonoPInvokeCallback attribute, since UnityEngine.AOT can't be found for whatever reason.
	// the custom attribute *should* work, as described here https://discussions.unity.com/t/help-with-aot-compilation-with-monopinvokecallback/752287/3
	[AttributeUsage(AttributeTargets.Method, Inherited = false, AllowMultiple = false)]
	internal sealed class MonoPInvokeCallbackAttribute : Attribute {
		public MonoPInvokeCallbackAttribute(Type delegateType) { }
	}
}
