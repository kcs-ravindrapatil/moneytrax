# Generated guidance from R8 missing_rules.txt (sqflite)
-dontwarn com.tekartik.sqflite.Database
-dontwarn com.tekartik.sqflite.DatabaseWorkerPool
-dontwarn com.tekartik.sqflite.Utils
-dontwarn com.tekartik.sqflite.operation.MethodCallOperation
-dontwarn com.tekartik.sqflite.operation.Operation
-keep class com.tekartik.sqflite.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Local notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**
# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
-dontwarn com.tekartik.sqflite.SqlCommand
-dontwarn com.tekartik.sqflite.operation.BaseOperation
-dontwarn com.tekartik.sqflite.operation.OperationResult