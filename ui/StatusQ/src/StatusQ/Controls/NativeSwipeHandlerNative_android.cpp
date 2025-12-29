#include <StatusQ/NativeSwipeHandlerNative.h>

#ifdef Q_OS_ANDROID

#include <QJniEnvironment>
#include <QJniObject>
#include <QPointer>
#include <QQuickWindow>
#include <QTimer>

class NativeSwipeHandlerNative_Android : public NativeSwipeHandlerNative
{
    Q_OBJECT

public:
    explicit NativeSwipeHandlerNative_Android(QQuickItem *parent = nullptr);
    ~NativeSwipeHandlerNative_Android() override;

protected:
    void setupGestureRecognition() override;
    void teardownGestureRecognition() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;
    void updatePolish() override;

private:
    void initializeJNI();
    void cleanupJNI();
    void updateOverlayBounds();
    void maybeUpdateCachedOpenDistance();

    qreal effectiveOpenDistance() const {
        if (openDistance() > 0.0) return openDistance();
        return m_cachedOpenDistance > 1.0 ? m_cachedOpenDistance : 280.0;
    }

    static void onSwipeBegan(JNIEnv *, jobject, jlong ptr, jfloat velocityX);
    static void onSwipeChanged(JNIEnv *, jobject, jlong ptr, jfloat deltaX, jfloat velocityX);
    static void onSwipeEnded(JNIEnv *, jobject, jlong ptr, jfloat deltaX, jfloat velocityX);

    QJniObject m_javaHelper;
    bool m_jniInitialized = false;

    QVector<QMetaObject::Connection> m_changeConnections;
    QVector<QMetaObject::Connection> m_windowConnections;

    bool m_active = false;
    qreal m_from = 0.0;
    qreal m_to = 1.0;
    qreal m_cachedOpenDistance = 0.0;
};

NativeSwipeHandlerNative_Android::NativeSwipeHandlerNative_Android(QQuickItem *parent)
    : NativeSwipeHandlerNative(parent)
{
    // Push bounds updates not only on size changes but also on x/y changes.
    m_changeConnections.append(connect(this, &QQuickItem::xChanged, this, [this]() { polish(); }));
    m_changeConnections.append(connect(this, &QQuickItem::yChanged, this, [this]() { polish(); }));
    m_changeConnections.append(connect(this, &QQuickItem::widthChanged, this, [this]() { polish(); }));
    m_changeConnections.append(connect(this, &QQuickItem::heightChanged, this, [this]() { polish(); }));
    m_changeConnections.append(connect(this, &QQuickItem::visibleChanged, this, [this]() { polish(); }));
    m_changeConnections.append(connect(this, &QQuickItem::enabledChanged, this, [this]() { polish(); }));
    QTimer::singleShot(0, this, [this]() { setupGestureRecognition(); });
}

NativeSwipeHandlerNative_Android::~NativeSwipeHandlerNative_Android()
{
    teardownGestureRecognition();
}

void NativeSwipeHandlerNative_Android::initializeJNI()
{
    if (m_jniInitialized)
        return;

    JNINativeMethod methods[] = {
        {"nativeOnSwipeBegan", "(JF)V", reinterpret_cast<void *>(onSwipeBegan)},
        {"nativeOnSwipeChanged", "(JFF)V", reinterpret_cast<void *>(onSwipeChanged)},
        {"nativeOnSwipeEnded", "(JFF)V", reinterpret_cast<void *>(onSwipeEnded)},
    };

    QJniEnvironment env;
    jclass javaClass = env.findClass("app/status/mobile/NativeSwipeHandlerHelper");
    if (javaClass) {
        env->RegisterNatives(javaClass, methods, sizeof(methods) / sizeof(methods[0]));
    }
    if (env->ExceptionCheck()) {
        env->ExceptionDescribe();
        env->ExceptionClear();
        return;
    }

    QJniObject activity = QJniObject::callStaticObjectMethod(
        "org/qtproject/qt/android/QtNative",
        "activity",
        "()Landroid/app/Activity;");
    if (!activity.isValid())
        return;

    m_javaHelper = QJniObject(
        "app/status/mobile/NativeSwipeHandlerHelper",
        "(JLandroid/app/Activity;)V",
        reinterpret_cast<jlong>(this),
        activity.object());

    if (!m_javaHelper.isValid())
        return;

    m_jniInitialized = true;
    updateOverlayBounds();
}

void NativeSwipeHandlerNative_Android::cleanupJNI()
{
    if (m_javaHelper.isValid()) {
        m_javaHelper.callMethod<void>("cleanup");
    }
    m_javaHelper = QJniObject();
    m_jniInitialized = false;
}

void NativeSwipeHandlerNative_Android::setupGestureRecognition()
{
    initializeJNI();
    polish();
}

void NativeSwipeHandlerNative_Android::teardownGestureRecognition()
{
    cleanupJNI();
    for (const auto &c : std::as_const(m_windowConnections))
        disconnect(c);
    m_windowConnections.clear();
}

void NativeSwipeHandlerNative_Android::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    NativeSwipeHandlerNative::geometryChange(newGeometry, oldGeometry);
    Q_UNUSED(oldGeometry)
    updateOverlayBounds();
}

void NativeSwipeHandlerNative_Android::itemChange(ItemChange change, const ItemChangeData &value)
{
    NativeSwipeHandlerNative::itemChange(change, value);
    if (change == ItemSceneChange) {
        if (value.window) {
            // Window can change/recreate on rotation; re-init JNI and re-push bounds.
            for (const auto &c : std::as_const(m_windowConnections))
                disconnect(c);
            m_windowConnections.clear();

            m_windowConnections.append(connect(value.window, &QQuickWindow::widthChanged, this, [this]() { polish(); }));
            m_windowConnections.append(connect(value.window, &QQuickWindow::heightChanged, this, [this]() { polish(); }));

            QTimer::singleShot(0, this, [this]() {
                teardownGestureRecognition();
                setupGestureRecognition();
            });
        }
        else teardownGestureRecognition();
    }
}

void NativeSwipeHandlerNative_Android::updatePolish()
{
    QQuickItem::updatePolish();
    updateOverlayBounds();
}

void NativeSwipeHandlerNative_Android::updateOverlayBounds()
{
    if (!m_javaHelper.isValid() || !window() || !isVisible() || !isEnabled())
        return;

    const QPointF scenePos = mapToScene(QPointF(0, 0));
    const qreal dpr = window()->effectiveDevicePixelRatio();
    const qreal xPx = scenePos.x() * dpr;
    const qreal yPx = scenePos.y() * dpr;
    const qreal wPx = width() * dpr;
    const qreal hPx = height() * dpr;

    m_javaHelper.callMethod<void>("updateTouchOverlayBounds", "(FFFF)V",
                                  static_cast<jfloat>(xPx),
                                  static_cast<jfloat>(yPx),
                                  static_cast<jfloat>(wPx),
                                  static_cast<jfloat>(hPx));
}

void NativeSwipeHandlerNative_Android::maybeUpdateCachedOpenDistance()
{
    if (!m_active && x() > 1.0)
        m_cachedOpenDistance = x();
}

void NativeSwipeHandlerNative_Android::onSwipeBegan(JNIEnv *, jobject, jlong ptr, jfloat)
{
    auto *self = reinterpret_cast<NativeSwipeHandlerNative_Android *>(ptr);
    if (!self || !self->window() || !self->isVisible() || !self->isEnabled())
        return;

    QPointer<NativeSwipeHandlerNative_Android> weak(self);
    QMetaObject::invokeMethod(self, [weak]() {
        if (!weak || !weak->window() || !weak->isVisible() || !weak->isEnabled())
            return;

        weak->maybeUpdateCachedOpenDistance();
        weak->m_active = true;

        const qreal openDist = weak->effectiveOpenDistance();
        const qreal currentPos = qMax<qreal>(0.0, qMin<qreal>(1.0, weak->x() / openDist));
        if (currentPos >= 0.5) { weak->m_from = 1.0; weak->m_to = 0.0; }
        else { weak->m_from = 0.0; weak->m_to = 1.0; }

        emit weak->swipeStarted(weak->m_from, weak->m_to);
    }, Qt::QueuedConnection);
}

void NativeSwipeHandlerNative_Android::onSwipeChanged(JNIEnv *, jobject, jlong ptr, jfloat deltaX, jfloat velocityX)
{
    auto *self = reinterpret_cast<NativeSwipeHandlerNative_Android *>(ptr);
    if (!self)
        return;

    QPointer<NativeSwipeHandlerNative_Android> weak(self);
    QMetaObject::invokeMethod(self, [weak, deltaX, velocityX]() {
        if (!weak || !weak->m_active || !weak->window() || !weak->isVisible() || !weak->isEnabled())
            return;

        const qreal dpr = weak->window()->effectiveDevicePixelRatio();
        const qreal delta = static_cast<qreal>(deltaX) / qMax<qreal>(1.0, dpr);
        const qreal velocity = static_cast<qreal>(velocityX) / qMax<qreal>(1.0, dpr);
        const qreal openDist = weak->effectiveOpenDistance();

        qreal position = 0.0;
        if (weak->m_from < weak->m_to) position = qMax<qreal>(0.0, qMin<qreal>(1.0, delta / openDist));
        else position = qMax<qreal>(0.0, qMin<qreal>(1.0, 1.0 + (delta / openDist)));

        emit weak->swipeProgress(position, weak->m_from, weak->m_to, velocity);
    }, Qt::QueuedConnection);
}

void NativeSwipeHandlerNative_Android::onSwipeEnded(JNIEnv *, jobject, jlong ptr, jfloat deltaX, jfloat velocityX)
{
    auto *self = reinterpret_cast<NativeSwipeHandlerNative_Android *>(ptr);
    if (!self)
        return;

    QPointer<NativeSwipeHandlerNative_Android> weak(self);
    QMetaObject::invokeMethod(self, [weak, deltaX, velocityX]() {
        if (!weak || !weak->m_active || !weak->window())
            return;

        const qreal dpr = weak->window()->effectiveDevicePixelRatio();
        const qreal delta = static_cast<qreal>(deltaX) / qMax<qreal>(1.0, dpr);
        const qreal v = static_cast<qreal>(velocityX) / qMax<qreal>(1.0, dpr);

        const qreal openDist = weak->effectiveOpenDistance();
        const bool fast = qAbs(v) > 500.0;
        const bool pastHalf = qAbs(delta) > (openDist * 0.5);
        const bool committed = fast || pastHalf;

        weak->m_active = false;
        emit weak->swipeEnded(committed, weak->m_from, weak->m_to, v);
    }, Qt::QueuedConnection);
}

void registerNativeSwipeHandlerNativeType()
{
    qmlRegisterType<NativeSwipeHandlerNative_Android>("StatusQ.Controls", 0, 1, "NativeSwipeHandlerNative");
}

#include "NativeSwipeHandlerNative_android.moc"

#endif // Q_OS_ANDROID


