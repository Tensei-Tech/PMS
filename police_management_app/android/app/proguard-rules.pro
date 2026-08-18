# Khakhi Diary — ProGuard / R8 Rules
# Domain 6: Code obfuscation and shrinking rules for release builds.

# ── Flutter Engine ─────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# ── Firebase ────────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ── Kotlin Coroutines ──────────────────────────────────────────────────────────
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**

# ── local_auth (Biometrics) ────────────────────────────────────────────────────
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# ── flutter_secure_storage ─────────────────────────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ── Suppress generic warnings ──────────────────────────────────────────────────
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# ── Security: Remove debug/log calls in release ────────────────────────────────
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
