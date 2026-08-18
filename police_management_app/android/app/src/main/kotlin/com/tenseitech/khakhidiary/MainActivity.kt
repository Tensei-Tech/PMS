package com.tenseitech.khakhidiary

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Domain 5: FLAG_SECURE — prevents screenshots and blurs the app
        // in the Android recents/task switcher. Critical for a law enforcement app.
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
