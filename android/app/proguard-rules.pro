# Add project specific ProGuard rules here.

# Google Maps SDK
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.maps.model.** { *; }

# Google Play Services
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

# Google Play Core (for Flutter deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep interface com.google.android.play.core.** { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable classes used by Maps
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Gson classes if used
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }
-keep class com.google.gson.examples.android.model.** { *; }

# Flutter Google Maps Plugin
-keep class io.flutter.plugins.googlemaps.** { *; }

# Keep classes that are referenced in AndroidManifest
-keep class com.waseyuser.app.** { *; }

# Keep model classes (in case you have custom model classes)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep annotation default values
-keepattributes AnnotationDefault

# Keep line numbers for debugging stack traces
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep classes for location services
-keep class com.google.android.gms.location.places.** { *; }

# Keep View constructors
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Keep native methods from being removed
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# =============================================================================
# Firebase
# =============================================================================

# Firebase Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# Firebase Common
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep Firebase model classes
-keep class com.google.firebase.firestore.** { *; }

# =============================================================================
# Facebook SDK
# =============================================================================

-keep class com.facebook.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.facebook.**

# Keep Facebook classes
-keep class com.facebook.share.** { *; }
-keep class com.facebook.login.** { *; }

# =============================================================================
# Flutter Plugins
# =============================================================================

# Flutter plugins that use reflection
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# =============================================================================
# Geolocator Plugin
# =============================================================================

-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# =============================================================================
# Additional optimizations for release builds
# =============================================================================

# Keep enum classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R class
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Don't warn about missing classes (optional libraries)
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# Preserve all annotation information
-keepattributes *Annotation*,InnerClasses

# Keep custom exceptions
-keep public class * extends java.lang.Exception
