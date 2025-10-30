package app.status.mobile;

import android.app.Activity;
import android.view.View;
import android.view.Window;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import java.util.concurrent.atomic.AtomicInteger;

public class KeyboardUtil {
    // Cached keyboard state (updated by WindowInsets listener)
    private static final AtomicInteger cachedKeyboardHeight = new AtomicInteger(0);
    private static boolean isListenerSetup = false;
    
    // Call this from Qt via JNI: KeyboardUtil.getKeyboardHeight(Activity)
    // Returns the current keyboard height in pixels, or 0 if keyboard is hidden
    public static int getKeyboardHeight(Activity activity) {
        setupListenerIfNeeded(activity);
        return cachedKeyboardHeight.get();
    }
    
    // Call this from Qt via JNI: KeyboardUtil.isKeyboardVisible(Activity)
    // Returns true if keyboard is currently visible, false otherwise
    public static boolean isKeyboardVisible(Activity activity) {
        return getKeyboardHeight(activity) > 0;
    }
    
    // Setup WindowInsets listener once to cache keyboard state
    private static void setupListenerIfNeeded(Activity activity) {
        if (isListenerSetup || activity == null) return;
        
        Window window = activity.getWindow();
        if (window == null) return;
        
        View decorView = window.getDecorView();
        ViewCompat.setOnApplyWindowInsetsListener(decorView, (view, windowInsets) -> {
            // Get IME (keyboard) insets and cache the height
            Insets imeInsets = windowInsets.getInsets(WindowInsetsCompat.Type.ime());
            cachedKeyboardHeight.set(imeInsets.bottom);
            
            // Return insets unchanged so other listeners still work
            return windowInsets;
        });
        
        isListenerSetup = true;
    }
}
