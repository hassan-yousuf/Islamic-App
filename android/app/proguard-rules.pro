# ────────────────────────────────────────────────────────────────
# Flutter Core
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter Entrypoints and MethodChannels
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class io.flutter.plugin.common.MethodChannel$MethodCallHandler { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.android.FlutterActivity { *; }

# Flutter Resource Access
-keep class **.R$* { *; }
-keep class * extends java.lang.annotation.Annotation { *; }

# ────────────────────────────────────────────────────────────────
# Adhan (Prayer Time Calculation)
-keep class com.batoulapps.adhan.** { *; }
-dontwarn com.batoulapps.adhan.**

# ────────────────────────────────────────────────────────────────
# JSON / Serialization
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# ────────────────────────────────────────────────────────────────
# UI Components & Custom Views (like progress indicators)
-keep class * extends android.view.View { *; }

# If you're using animation or percent indicator packages
-keep class **.percentindicator.** { *; }
-keep class **.animation.** { *; }

# ────────────────────────────────────────────────────────────────
# Kotlin & Misc Libraries
-dontwarn okio.**
-dontwarn javax.annotation.**

# ────────────────────────────────────────────────────────────────
# Debugging Support (Optional)
#-keep class kotlinx.coroutines.** { *; }       # if you're using coroutines
#-keepclassmembers class kotlinx.coroutines.** { *; }

# Adhan package
-keep class com.batoulapps.adhan.** { *; }

# Keep Flutter JSON model classes if you're using toJson/fromJson
-keepclassmembers class * {
    @androidx.annotation.Keep <methods>;
}

-keep class * extends java.time.temporal.Temporal { *; }
-keep class * extends java.time.chrono.ChronoLocalDate { *; }

# Preserve all classes and methods in the Adhan package (if using a local Java binding version)
-keep class adhan.** { *; }

# Keep Play Core split install classes
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
