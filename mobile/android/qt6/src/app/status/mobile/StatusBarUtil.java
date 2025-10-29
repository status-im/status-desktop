package app.status.mobile;

import android.app.Activity;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.view.WindowInsetsController;

public class StatusBarUtil {
    // Call this from Qt via JNI: StatusBarUtil.setStatusBarIconColor(Activity, boolean)
    // If lightIcons is true, icons are white. If false, icons are dark (black).
    public static void setStatusBarIconColor(Activity activity, boolean lightIcons) {
        if (activity == null) return;
        
        // Ensure UI operations run on the main thread
        activity.runOnUiThread(() -> {
            Window window = activity.getWindow();
            if (window == null) return;

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                WindowInsetsController controller = window.getInsetsController();
                if (controller != null) {
                    if (lightIcons) {
                        // White icons on status bar and navigation bar
                        controller.setSystemBarsAppearance(0, 
                            WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS | 
                            WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS);
                    } else {
                        // Dark icons on status bar and navigation bar
                        controller.setSystemBarsAppearance(
                            WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS | 
                            WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS,
                            WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS | 
                            WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS);
                    }
                }
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                View decor = window.getDecorView();
                int flags = decor.getSystemUiVisibility();
                if (lightIcons) {
                    // Remove flags for white icons
                    flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        flags &= ~View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
                    }
                } else {
                    // Add flags for dark icons
                    flags |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        flags |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
                    }
                }
                decor.setSystemUiVisibility(flags);
            }
        });
    }
}
