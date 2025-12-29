package app.status.mobile;

import android.app.Activity;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

public class NativeSwipeHandlerHelper {
    private final long nativePtr;
    private final Activity activity;
    private View touchOverlayView;

    // Track in screen coordinates so moving the overlay view during the gesture doesn't distort deltas.
    private float startRawX = 0.0f;
    private float lastRawX = 0.0f;
    private long lastEventTimeMs = 0;
    private float lastVx = 0.0f;
    private boolean active = false;
    private int activePointerId = -1;
    // VelocityTracker uses view-local coords; we compute velocity from rawX instead.
    private VelocityTracker velocityTracker;

    // Handler rect in parent pixels (contentView coordinates).
    private float handlerX = 0.0f;
    private float handlerY = 0.0f;
    private float handlerWidth = 20.0f;
    private float handlerHeight = 20.0f;

    private static native void nativeOnSwipeBegan(long ptr, float velocityX);
    private static native void nativeOnSwipeChanged(long ptr, float deltaX, float velocityX);
    private static native void nativeOnSwipeEnded(long ptr, float deltaX, float velocityX);

    public NativeSwipeHandlerHelper(long ptr, Activity activity) {
        this.nativePtr = ptr;
        this.activity = activity;

        createTouchOverlay();
    }

    private void createTouchOverlay() {
        activity.runOnUiThread(() -> {
            touchOverlayView = new View(activity);
            touchOverlayView.setBackgroundColor(0x00000000);

            ViewGroup contentView = (ViewGroup) activity.getWindow().getDecorView().findViewById(android.R.id.content);
            if (contentView == null)
                return;

            FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
                (int) Math.max(1, handlerWidth),
                (int) Math.max(1, handlerHeight)
            );
            touchOverlayView.setLayoutParams(params);
            touchOverlayView.setX(handlerX);
            touchOverlayView.setY(handlerY);
            touchOverlayView.setClickable(true);
            touchOverlayView.setLongClickable(false);

            touchOverlayView.setOnTouchListener((v, event) -> {
                final int action = event.getActionMasked();

                if (action == MotionEvent.ACTION_DOWN) {
                    // The overlay view is sized/positioned to the swipe rect, so any DOWN here is in-bounds.
                    final float x = event.getX();
                    final float rawX = event.getRawX();

                    active = true;
                    activePointerId = event.getPointerId(0);
                    startRawX = rawX;
                    lastRawX = rawX;
                    lastEventTimeMs = event.getEventTime();
                    lastVx = 0.0f;

                    if (velocityTracker != null) {
                        velocityTracker.recycle();
                        velocityTracker = null;
                    }
                    velocityTracker = VelocityTracker.obtain();
                    velocityTracker.addMovement(event);

                    // Prevent parents from intercepting once we start.
                    if (touchOverlayView.getParent() instanceof ViewGroup) {
                        ((ViewGroup) touchOverlayView.getParent()).requestDisallowInterceptTouchEvent(true);
                    }

                    nativeOnSwipeBegan(nativePtr, 0.0f);
                    return true;
                }

                if (!active) {
                    return false;
                }

                // Keep tracking even if the finger moves out of the original edge bounds.
                if (velocityTracker != null) {
                    velocityTracker.addMovement(event);
                    velocityTracker.computeCurrentVelocity(1000);
                }

                final int idx = activePointerId >= 0 ? event.findPointerIndex(activePointerId) : 0;
                final float x = idx >= 0 ? event.getX(idx) : event.getX();
                final float rawX = idx >= 0 ? event.getRawX(idx) : event.getRawX();
                final long t = event.getEventTime();
                final long dt = Math.max(1, t - lastEventTimeMs);
                final float vx = ((rawX - lastRawX) / (float) dt) * 1000.0f;
                lastRawX = rawX;
                lastEventTimeMs = t;

                if (action == MotionEvent.ACTION_MOVE) {
                    final float dx = rawX - startRawX;
                    lastVx = vx;
                    nativeOnSwipeChanged(nativePtr, dx, vx);
                    return true;
                }

                if (action == MotionEvent.ACTION_UP || action == MotionEvent.ACTION_CANCEL) {
                    final float dx = rawX - startRawX;
                    // Use the last MOVE velocity; UP often has vx≈0 because there's no delta.
                    nativeOnSwipeEnded(nativePtr, dx, lastVx);

                    if (velocityTracker != null) {
                        velocityTracker.recycle();
                        velocityTracker = null;
                    }
                    active = false;
                    activePointerId = -1;
                    return true;
                }

                return true;
            });

            contentView.addView(touchOverlayView);
        });
    }

    public void updateTouchOverlayBounds(float xPx, float yPx, float widthPx, float heightPx) {
        handlerX = xPx;
        handlerY = yPx;
        handlerWidth = widthPx;
        handlerHeight = heightPx;

        if (activity != null) {
            activity.runOnUiThread(() -> {
                if (touchOverlayView == null) return;
                // Re-attach if rotation/activity changes detached the view.
                if (touchOverlayView.getParent() == null) {
                    ViewGroup contentView = (ViewGroup) activity.getWindow().getDecorView().findViewById(android.R.id.content);
                    if (contentView != null) {
                        contentView.addView(touchOverlayView);
                    }
                }
                // If a swipe is active, don't move/resize the overlay underneath the finger.
                // The view will continue receiving events anyway once it has captured ACTION_DOWN.
                if (active) return;
                ViewGroup.LayoutParams lp = touchOverlayView.getLayoutParams();
                if (lp != null) {
                    lp.width = (int) Math.max(1, handlerWidth);
                    lp.height = (int) Math.max(1, handlerHeight);
                    touchOverlayView.setLayoutParams(lp);
                }
                touchOverlayView.setX(handlerX);
                touchOverlayView.setY(handlerY);
            });
        }
    }

    public void cleanup() {
        if (activity == null) return;
        activity.runOnUiThread(() -> {
            if (touchOverlayView != null) {
                ViewGroup parent = (ViewGroup) touchOverlayView.getParent();
                if (parent != null) parent.removeView(touchOverlayView);
                touchOverlayView = null;
            }

            if (velocityTracker != null) {
                velocityTracker.recycle();
                velocityTracker = null;
            }
            active = false;
            activePointerId = -1;
        });
    }
}


