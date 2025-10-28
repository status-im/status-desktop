package app.status.mobile;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.view.inputmethod.InputMethodManager;
import android.content.Context;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import android.os.Build;

/**
 * Android 16 Keyboard Workaround for QTBUG-140897
 * 
 * This entire file can be deleted when Qt 6.10+ fixes the keyboard issue.
 * 
 * Problem: On Android 16, Qt's hasValidFocusObject() checks isInputPanelVisible()
 * before responding to Android's JNI queries, causing keyboard show to fail on first tap.
 * 
 * Solution: Automatically simulate a "second tap" by clearing and re-requesting focus
 * after 150ms, which makes Qt cooperate with Android's keyboard request.
 * 
 * @see https://bugreports.qt.io/browse/QTBUG-140897
 */
public class Android16KeyboardWorkaround {
    
    private static final boolean ENABLED = true;
    private static final int RETRY_DELAY_MS = 100;
    private static final int REFOCUS_DELAY_MS = 50;
    private static final int CLEANUP_DELAY_MS = 100;
    
    private final Activity mActivity;
    private final InputMethodManager mInputMethodManager;
    private final WindowInsetsControllerCompat mInsetsControllerCompat;
    private final WindowInsetsController mInsetsController;
    private final Handler mHandler;
    
    // State tracking
    private int mKeyboardAttemptCount = 0;
    private View mLastFocusedEditor = null;
    private boolean mIsRetryInProgress = false;
    private Runnable mScheduledRetry = null;

    /**
     * Create and initialize the keyboard workaround.
     * 
     * @param activity The activity to apply the workaround to
     * @return The workaround instance, or null if not needed
     */
    public static Android16KeyboardWorkaround install(Activity activity) {
        if (!ENABLED || Build.VERSION.SDK_INT < 35) { // Android 16 is API 35
            return null;
        }
        
        Android16KeyboardWorkaround workaround = new Android16KeyboardWorkaround(activity);
        workaround.setupFocusListener();
        return workaround;
    }

    private Android16KeyboardWorkaround(Activity activity) {
        mActivity = activity;
        mInputMethodManager = (InputMethodManager) activity.getSystemService(Context.INPUT_METHOD_SERVICE);
        mHandler = new Handler(Looper.getMainLooper());
        
        View decorView = activity.getWindow().getDecorView();
        mInsetsControllerCompat = new WindowInsetsControllerCompat(activity.getWindow(), decorView);
        
        if (Build.VERSION.SDK_INT >= 30) {
            mInsetsController = activity.getWindow().getInsetsController();
        } else {
            mInsetsController = null;
        }
    }

    /**
     * Set up the global focus listener that triggers the workaround.
     */
    private void setupFocusListener() {
        View decorView = mActivity.getWindow().getDecorView();
        decorView.getViewTreeObserver().addOnGlobalFocusChangeListener(
            (View oldFocus, View newFocus) -> {
                if (newFocus != null && newFocus.onCheckIsTextEditor()) {
                    handleTextEditorFocused(newFocus);
                } else {
                    handleTextEditorUnfocused();
                }
            }
        );
    }

    /**
     * Handle when a text editor receives focus.
     * 
     * Strategy:
     * - First focus (attempt 1): Show keyboard, schedule retry for later
     * - Retry: Clear focus, then request focus again (simulates "second tap")
     * - Second attempt: Show keyboard again (this time Qt cooperates)
     */
    private void handleTextEditorFocused(View editor) {
        boolean isNewEditor = (editor != mLastFocusedEditor);
        mLastFocusedEditor = editor;
        
        // Reset counter for new editor (but not during retry cycle)
        if (isNewEditor && !mIsRetryInProgress) {
            mKeyboardAttemptCount = 0;
            cancelScheduledRetry();
        }
        
        // Increment attempt counter (unless we're in a retry cycle)
        if (!mIsRetryInProgress) {
            mKeyboardAttemptCount++;
        }
        
        // Show keyboard via all available APIs
        requestKeyboardShow(editor);
        
        // Schedule automatic retry for first attempt
        if (mKeyboardAttemptCount == 1 && !mIsRetryInProgress) {
            scheduleKeyboardRetry(editor);
        }
    }

    /**
     * Handle when a text editor loses focus.
     */
    private void handleTextEditorUnfocused() {
        // Don't reset state if we're intentionally clearing focus during retry
        if (mIsRetryInProgress) {
            return;
        }
        
        // Editor lost focus - cancel any pending retry and reset state
        cancelScheduledRetry();
        mKeyboardAttemptCount = 0;
        mLastFocusedEditor = null;
    }

    /**
     * Schedule an automatic keyboard retry after a delay.
     * This simulates a "second tap" which always works on Android 16.
     */
    private void scheduleKeyboardRetry(View editor) {
        mScheduledRetry = () -> {
            // Set flag to prevent state reset during focus clear/request cycle
            mIsRetryInProgress = true;
            mKeyboardAttemptCount = 2; // Pre-set to 2 before retry
            
            // Simulate second tap: clear focus, then request it again
            editor.clearFocus();
            mHandler.postDelayed(() -> {
                editor.requestFocus();
                // Clear retry flag after keyboard request completes
                mHandler.postDelayed(() -> {
                    mIsRetryInProgress = false;
                }, CLEANUP_DELAY_MS);
            }, REFOCUS_DELAY_MS);
            
            mScheduledRetry = null;
        };
        
        mHandler.postDelayed(mScheduledRetry, RETRY_DELAY_MS);
    }

    /**
     * Cancel any pending keyboard retry.
     */
    private void cancelScheduledRetry() {
        if (mScheduledRetry != null) {
            mHandler.removeCallbacks(mScheduledRetry);
            mScheduledRetry = null;
        }
    }

    /**
     * Request keyboard show using multiple Android APIs simultaneously.
     * This increases chances of success since Qt's request may be unreliable.
     */
    private void requestKeyboardShow(View editor) {
        editor.post(() -> {
            // Method 1: InputMethodManager (standard Android API)
            mInputMethodManager.showSoftInput(editor, InputMethodManager.SHOW_IMPLICIT);
            
            // Method 2: AndroidX WindowInsetsController (modern, more reliable)
            mInsetsControllerCompat.show(WindowInsetsCompat.Type.ime());
            
            // Method 3: Platform WindowInsetsController (API 30+, most direct)
            if (mInsetsController != null) {
                mInsetsController.show(WindowInsets.Type.ime());
            }
        });
    }

    /**
     * Clean up resources when the workaround is no longer needed.
     * Call this in onDestroy() if you need to clean up.
     */
    public void cleanup() {
        cancelScheduledRetry();
        mKeyboardAttemptCount = 0;
        mLastFocusedEditor = null;
        mIsRetryInProgress = false;
    }
}

