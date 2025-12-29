#include <StatusQ/NativeIndicatorNative.h>

#ifdef Q_OS_ANDROID

#include <QBuffer>
#include <QImage>
#include <QJniEnvironment>
#include <QJniObject>
#include <QPainter>
#include <QPointer>
#include <QQuickWindow>
#include <QSvgRenderer>
#include <QTimer>

class NativeIndicatorNative_Android : public NativeIndicatorNative
{
    Q_OBJECT

public:
    explicit NativeIndicatorNative_Android(QQuickItem *parent = nullptr);
    ~NativeIndicatorNative_Android() override;

protected:
    void syncToNative() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;
    void updatePolish() override;

private:
    void initializeJNI();
    void cleanupJNI();
    void attachParentWatchers();
    void detachParentWatchers();
    void updateImageIfNeeded();
    void updateLayout();

    QPointer<QQuickItem> m_parentItem;
    QVector<QMetaObject::Connection> m_parentConnections;

    QJniObject m_javaHelper;
    bool m_jniInitialized = false;

    QUrl m_lastSource;
    QSize m_lastPixelSize;
};

NativeIndicatorNative_Android::NativeIndicatorNative_Android(QQuickItem *parent)
    : NativeIndicatorNative(parent)
{
    connect(this, &NativeIndicatorNative::sourceChanged, this, [this]() { polish(); });
    // IMPORTANT: x/y changes do NOT necessarily trigger geometryChange().
    // We must update layout for position-driven animations (e.g. sidebar snapping).
    connect(this, &QQuickItem::xChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::yChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::widthChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::heightChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::visibleChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::enabledChanged, this, [this]() { polish(); });
    QTimer::singleShot(0, this, [this]() { polish(); });
}

NativeIndicatorNative_Android::~NativeIndicatorNative_Android()
{
    detachParentWatchers();
    cleanupJNI();
}

void NativeIndicatorNative_Android::initializeJNI()
{
    if (m_jniInitialized)
        return;

    QJniObject activity = QJniObject::callStaticObjectMethod(
        "org/qtproject/qt/android/QtNative",
        "activity",
        "()Landroid/app/Activity;");
    if (!activity.isValid())
        return;

    m_javaHelper = QJniObject("app/status/mobile/NativeIndicatorHelper",
                              "(Landroid/app/Activity;)V",
                              activity.object());
    if (!m_javaHelper.isValid())
        return;

    m_jniInitialized = true;
}

void NativeIndicatorNative_Android::cleanupJNI()
{
    if (m_javaHelper.isValid()) {
        m_javaHelper.callMethod<void>("cleanup");
    }
    m_javaHelper = QJniObject();
    m_jniInitialized = false;
}

void NativeIndicatorNative_Android::attachParentWatchers()
{
    detachParentWatchers();
    m_parentItem = parentItem();
    if (!m_parentItem)
        return;

    m_parentConnections.append(connect(m_parentItem, &QQuickItem::xChanged, this, [this]() { polish(); }));
    m_parentConnections.append(connect(m_parentItem, &QQuickItem::yChanged, this, [this]() { polish(); }));
    m_parentConnections.append(connect(m_parentItem, &QQuickItem::widthChanged, this, [this]() { polish(); }));
    m_parentConnections.append(connect(m_parentItem, &QQuickItem::heightChanged, this, [this]() { polish(); }));
    m_parentConnections.append(connect(m_parentItem, &QQuickItem::clipChanged, this, [this]() { polish(); }));
    m_parentConnections.append(connect(m_parentItem, &QQuickItem::visibleChanged, this, [this]() { polish(); }));
}

void NativeIndicatorNative_Android::detachParentWatchers()
{
    for (const auto &c : std::as_const(m_parentConnections))
        disconnect(c);
    m_parentConnections.clear();
    m_parentItem.clear();
}

void NativeIndicatorNative_Android::itemChange(ItemChange change, const ItemChangeData &value)
{
    NativeIndicatorNative::itemChange(change, value);
    if (change == ItemSceneChange) {
        if (value.window) QTimer::singleShot(0, this, [this]() { polish(); });
        else { detachParentWatchers(); cleanupJNI(); }
    } else if (change == ItemParentHasChanged) {
        attachParentWatchers();
        polish();
    }
}

void NativeIndicatorNative_Android::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    NativeIndicatorNative::geometryChange(newGeometry, oldGeometry);
    Q_UNUSED(oldGeometry)
    polish();
}

void NativeIndicatorNative_Android::updatePolish()
{
    QQuickItem::updatePolish();
    syncToNative();
}

void NativeIndicatorNative_Android::syncToNative()
{
    if (!window())
        return;

    // Always initialize and push layout so we can *hide* the native view when QML visible/enabled flips.
    initializeJNI();
    attachParentWatchers();
    if (!m_javaHelper.isValid())
        return;

    // Only (re)rasterize when the item is actually meant to be visible.
    if (isVisible() && isEnabled())
        updateImageIfNeeded();

    updateLayout();
}

void NativeIndicatorNative_Android::updateImageIfNeeded()
{
    const QUrl src = source();
    if (src.isEmpty() || !window() || !m_javaHelper.isValid())
        return;

    const qreal dpr = window()->effectiveDevicePixelRatio();
    const QSize pixelSize(qMax(1, int(width() * dpr)), qMax(1, int(height() * dpr)));
    if (src == m_lastSource && pixelSize == m_lastPixelSize)
        return;

    QString path;
    if (src.isLocalFile()) path = src.toLocalFile();
    else if (src.scheme() == QLatin1String("qrc")) path = QLatin1Char(':') + src.path();
    else path = src.toString();

    QSvgRenderer renderer(path);
    if (!renderer.isValid())
        return;

    QImage img(pixelSize, QImage::Format_ARGB32_Premultiplied);
    img.fill(Qt::transparent);
    QPainter p(&img);
    p.setRenderHint(QPainter::Antialiasing, true);
    p.setRenderHint(QPainter::SmoothPixmapTransform, true);
    renderer.render(&p, QRectF(0, 0, pixelSize.width(), pixelSize.height()));
    p.end();

    QByteArray png;
    QBuffer buf(&png);
    buf.open(QIODevice::WriteOnly);
    img.save(&buf, "PNG");

    QJniEnvironment env;
    jbyteArray bytes = env->NewByteArray(png.size());
    env->SetByteArrayRegion(bytes, 0, png.size(), reinterpret_cast<const jbyte *>(png.constData()));
    m_javaHelper.callMethod<void>("updateBitmap", "([B)V", bytes);
    env->DeleteLocalRef(bytes);

    m_lastSource = src;
    m_lastPixelSize = pixelSize;
}

void NativeIndicatorNative_Android::updateLayout()
{
    if (!window() || !m_javaHelper.isValid())
        return;

    QQuickItem *pItem = parentItem();
    const bool clip = pItem ? pItem->clip() : false;

    QPointF parentScenePos(0, 0);
    QSizeF parentSize(window()->width(), window()->height());
    if (pItem) {
        parentScenePos = pItem->mapToScene(QPointF(0, 0));
        parentSize = QSizeF(pItem->width(), pItem->height());
    }

    QPointF indicatorScenePos = mapToScene(QPointF(0, 0));
    const qreal localX = indicatorScenePos.x() - parentScenePos.x();
    const qreal localY = indicatorScenePos.y() - parentScenePos.y();

    const qreal dpr = window()->effectiveDevicePixelRatio();
    const qreal containerX = parentScenePos.x() * dpr;
    const qreal containerY = parentScenePos.y() * dpr;
    const qreal containerW = parentSize.width() * dpr;
    const qreal containerH = parentSize.height() * dpr;

    const qreal imgX = localX * dpr;
    const qreal imgY = localY * dpr;
    const qreal imgW = width() * dpr;
    const qreal imgH = height() * dpr;

    const bool visible = isVisible() && isEnabled() && (!pItem || pItem->isVisible());

    m_javaHelper.callMethod<void>(
        "updateLayout",
        "(FFFFFFFFZZ)V",
        static_cast<jfloat>(containerX),
        static_cast<jfloat>(containerY),
        static_cast<jfloat>(containerW),
        static_cast<jfloat>(containerH),
        static_cast<jfloat>(imgX),
        static_cast<jfloat>(imgY),
        static_cast<jfloat>(imgW),
        static_cast<jfloat>(imgH),
        static_cast<jboolean>(visible),
        static_cast<jboolean>(clip));
}

void registerNativeIndicatorNativeType()
{
    qmlRegisterType<NativeIndicatorNative_Android>("StatusQ.Controls", 0, 1, "NativeIndicatorNative");
}

#include "NativeIndicatorNative_android.moc"

#endif // Q_OS_ANDROID


