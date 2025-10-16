package im.status.app;

import org.qtproject.qt.android.bindings.QtActivity;
import android.os.Build;
import android.os.Bundle;
import androidx.core.splashscreen.SplashScreen;
import java.util.concurrent.atomic.AtomicBoolean;

public class StatusQtActivity extends QtActivity {
    private static final AtomicBoolean splashShouldHide = new AtomicBoolean(false);

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT >= 31) { // Android 12+
                SplashScreen splashScreen = SplashScreen.installSplashScreen(this);
                splashScreen.setKeepOnScreenCondition(() -> !splashShouldHide.get());
        }
    }

    // Called from Qt via JNI when main window is visible
    public static void hideSplashScreen() {
        splashShouldHide.set(true);
    }
}
