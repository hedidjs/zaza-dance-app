# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Keep all Flutter and Dart classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Supabase classes
-keep class io.supabase.** { *; }

# Keep Riverpod classes  
-keep class com.riverpod.** { *; }

# Keep Google Fonts
-keep class com.google.fonts.** { *; }

# Keep video player classes
-keep class video_player.** { *; }

# Keep image picker classes
-keep class image_picker.** { *; }

# Keep cached network image classes
-keep class cached_network_image.** { *; }

# Keep model classes (add your specific model package)
-keep class com.zazadance.zaza_dance.** { *; }

# Keep Google Play Core classes for Flutter
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Google Tasks classes
-keep class com.google.android.gms.tasks.** { *; }
-dontwarn com.google.android.gms.tasks.**

# Keep MultiDex classes
-keep class androidx.multidex.** { *; }
-dontwarn androidx.multidex.**

# Keep Android system classes to prevent warnings
-dontwarn android.os.**
-dontwarn com.samsung.**
-dontwarn com.sec.**

# Keep Binder classes
-keep class android.os.Binder { *; }
-keep class android.os.IBinder { *; }

# Prevent Samsung specific warnings
-dontwarn com.samsung.knox.**
-dontwarn com.samsung.android.**

# Performance optimizations
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Keep native method names
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep serialization classes
-keepnames class ** implements java.io.Serializable
-keepclassmembers class ** implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}