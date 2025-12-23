package app.status.mobile;

import org.qtproject.qt.android.bindings.QtActivity;
import android.os.Build;
import android.os.Bundle;
import androidx.core.splashscreen.SplashScreen;
import java.util.concurrent.atomic.AtomicBoolean;
import android.content.Intent;
import android.app.PendingIntent;
import android.nfc.NfcAdapter;
import android.util.Log;

public class StatusQtActivity extends QtActivity {
    private static final String TAG = "StatusQtActivity";
    private static final AtomicBoolean splashShouldHide = new AtomicBoolean(false);
    
    // NFC Foreground Dispatch members
    // CRITICAL: These enable NFC detection to work immediately at app startup
    private NfcAdapter mNfcAdapter;
    private PendingIntent mPendingIntent;
    
    // QTBUG-140897: Android 16 keyboard workaround
    // Remove this line when Qt 6.10+ fixes the issue, and delete Android16KeyboardWorkaround.java
    private Android16KeyboardWorkaround mKeyboardWorkaround;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        if (Build.VERSION.SDK_INT >= 31) { // Android 12+
            SplashScreen splashScreen = SplashScreen.installSplashScreen(this);
            splashScreen.setKeepOnScreenCondition(() -> !splashShouldHide.get());
        }
        
        // QTBUG-140897: Install Android 16 keyboard workaround
        // Remove this line when Qt 6.10+ fixes the issue
        mKeyboardWorkaround = Android16KeyboardWorkaround.install(this);
        
        // CRITICAL: Initialize NFC for Foreground Dispatch
        // This ensures Qt NFC detection works immediately at app startup.
        // Without this initialization, Qt's NFC detection fails until the app
        // goes through a background→foreground cycle.
        mNfcAdapter = NfcAdapter.getDefaultAdapter(this);
        if (mNfcAdapter == null) {
            Log.d(TAG, "NFC not available on this device");
        } else {
            // Create a PendingIntent for NFC tag discovery
            Intent intent = new Intent(this, getClass()).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
            int flags = PendingIntent.FLAG_MUTABLE | PendingIntent.FLAG_UPDATE_CURRENT;
            mPendingIntent = PendingIntent.getActivity(this, 0, intent, flags);
            Log.d(TAG, "NFC Foreground Dispatch initialized");
        }
    }
    
    // Track if foreground dispatch is enabled
    private boolean mForegroundDispatchEnabled = false;
    
    // Static reference to the current activity instance
    private static StatusQtActivity sInstance = null;
    
    @Override
    protected void onResume() {
        super.onResume();
        sInstance = this;
        
        Log.d(TAG, "===== onResume: Setting up NFC Foreground Dispatch =====");
        
        // CRITICAL: Enable Foreground Dispatch here to fix Qt NFC startup issue
        // 
        // Problem: Qt's NFC backend calls enableForegroundDispatch() during initialization,
        // but this happens too early - before the Activity is fully ready. This causes
        // Qt NFC detection to fail silently until the app goes background→foreground.
        //
        // Solution: We enable Foreground Dispatch here in onResume(), which is guaranteed
        // to run after the Activity is fully ready. This ensures NFC detection works
        // immediately at app startup.
        //
        // Note: Only enable if not already enabled to avoid disrupting active NFC connections
        if (mNfcAdapter != null && mPendingIntent != null && !mForegroundDispatchEnabled) {
            try {
                mNfcAdapter.enableForegroundDispatch(this, mPendingIntent, null, null);
                mForegroundDispatchEnabled = true;
                Log.d(TAG, "NFC Foreground Dispatch ENABLED (Qt detection will work)");
            } catch (Exception e) {
                Log.e(TAG, "Error enabling Foreground Dispatch: " + e.getMessage());
            }
        } else if (mForegroundDispatchEnabled) {
            Log.d(TAG, "NFC Foreground Dispatch already enabled");
        } else {
            Log.w(TAG, "Cannot enable Foreground Dispatch - adapter or intent is null");
        }
    }
    
    @Override
    protected void onPause() {
        super.onPause();
        
        // Disable Foreground Dispatch when activity is paused
        // This is standard Android practice to allow other apps to receive NFC events
        if (mNfcAdapter != null && mForegroundDispatchEnabled) {
            try {
                mNfcAdapter.disableForegroundDispatch(this);
                mForegroundDispatchEnabled = false;
                Log.d(TAG, "NFC Foreground Dispatch DISABLED");
            } catch (Exception e) {
                Log.e(TAG, "Error disabling Foreground Dispatch: " + e.getMessage());
            }
        }
        
        if (sInstance == this) {
            sInstance = null;
        }
    }

    @Override
    protected void onDestroy() {
        // QTBUG-140897: Cleanup workaround resources
        // Remove this when Qt 6.10+ fixes the issue
        if (mKeyboardWorkaround != null) {
            mKeyboardWorkaround.cleanup();
            mKeyboardWorkaround = null;
        }
        
        super.onDestroy();
    }

    // Called from Qt via JNI when main window is visible
    public static void hideSplashScreen() {
        splashShouldHide.set(true);
    }
}
