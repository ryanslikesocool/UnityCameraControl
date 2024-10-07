#if UNITY_IOS
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;

namespace CameraControl.Editor {
	internal static class BuildPostProcessor {
		[PostProcessBuild]
		public static void OnPostProcessBuild(BuildTarget buildTarget, string buildPath) {
			if (buildTarget == BuildTarget.iOS) {
				string projectPath = buildPath + "/Unity-iPhone.xcodeproj/project.pbxproj";

				PBXProject project = new PBXProject();
				project.ReadFromFile(projectPath);

				var unityFrameworkGuid = project.GetUnityFrameworkTargetGuid();

				// Modulemap
				project.AddBuildProperty(unityFrameworkGuid, "DEFINES_MODULE", "YES");

				string moduleFile = buildPath + "/UnityFramework/UnityFramework.modulemap";
				if (!File.Exists(moduleFile)) {
					FileUtil.CopyFileOrDirectory(MODULEMAP_PATH, moduleFile);
					project.AddFile(moduleFile, "UnityFramework/UnityFramework.modulemap");
					project.AddBuildProperty(unityFrameworkGuid, "MODULEMAP_FILE", "$(SRCROOT)/UnityFramework/UnityFramework.modulemap");
				}

				// Headers
				AddHeader(ref project, unityFrameworkGuid, "UnityInterface.h");
				AddHeader(ref project, unityFrameworkGuid, "UnityForwardDecls.h");
				AddHeader(ref project, unityFrameworkGuid, "UnityRendering.h");
				AddHeader(ref project, unityFrameworkGuid, "UnitySharedDecls.h");

				// Save project
				project.WriteToFile(projectPath);
			}
		}

		private static void AddHeader(ref PBXProject project, in string unityFrameworkGuid, in string headerFileName) {
			string headerPath = Path.Combine(UNITY_CLASS_DIRECTORY, headerFileName);
			string headerGuid = project.FindFileGuidByProjectPath(headerPath);
			project.AddPublicHeaderToBuild(unityFrameworkGuid, headerGuid);
		}

		// MARK: - Constants

		private const string UNITY_CLASS_DIRECTORY = "Classes/Unity";

		private const string MODULEMAP_PATH = "Packages/com.developedwithlove.cameracontrol/Runtime/Plugins/iOS/CameraControl/UnityFramework.modulemap";
		//private const string MODULEMAP_PATH = "Assets/Plugins/iOS/SwiftToUnity/Source/UnityFramework.modulemap";
	}
}
#endif
