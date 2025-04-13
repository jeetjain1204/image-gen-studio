#########################################
# 📦 FLUTTER WRAPPER & ENGINE
#########################################
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

#########################################
# 🔥 FIREBASE & GOOGLE SERVICES
#########################################
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.perf.** { *; }
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.crashlytics.** { *; }
-keep class com.google.analytics.** { *; }
-keep class com.google.android.gms.analytics.** { *; }

#########################################
# 💰 GOOGLE MOBILE ADS
#########################################
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.internal.ads.** { *; }

#########################################
# 🧩 PLAY CORE / DEFERRED COMPONENTS
#########################################
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallManagerFactory { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallSessionState { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keep class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.common.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Play Store Split App
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

#########################################
# 🏠 YOUR APP PACKAGE
#########################################
-keep class com.infinitylab.aadi.** { *; }

#########################################
# ⚙️ GENERAL AND SYSTEM RULES
#########################################
-keepclasseswithmembernames class * {
    native <methods>;
}
-keep class * implements android.os.Parcelable {
    static ** CREATOR;
}
-keepnames class * implements java.io.Serializable
-keep class **.R$* {
    *;
}
-keep public class * extends java.lang.Exception

#########################################
# 🌐 WEBVIEW & JAVASCRIPT
#########################################
-keep class android.webkit.WebView { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

#########################################
# 🐛 DEBUG INFO
#########################################
-keepattributes SourceFile,LineNumberTable
