# Add project specific ProGuard rules here.

# Google Maps SDK
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-keep class com.google.android.gms.maps.model.** { *; }

# Google Play Services
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

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
