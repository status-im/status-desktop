#include <StatusQ/NativeIndicatorNative.h>

#ifdef Q_OS_MACOS

#import <AppKit/AppKit.h>

#include <QBuffer>
#include <QImage>
#include <QPainter>
#include <QPointer>
#include <QQuickWindow>
#include <QSvgRenderer>
#include <QTimer>

class NativeIndicatorNative_macOS : public NativeIndicatorNative
{
    Q_OBJECT

public:
    explicit NativeIndicatorNative_macOS(QQuickItem *parent = nullptr);
    ~NativeIndicatorNative_macOS() override;

protected:
    void syncToNative() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;
    void updatePolish() override;

private:
    NSView *getNSView() const;
    void ensureViews();
    void destroyViews();
    void updateImageIfNeeded();
    void updateFramesAndVisibility();

    void attachParentWatchers();
    void detachParentWatchers();

    QPointer<QQuickItem> m_parentItem;
    QVector<QMetaObject::Connection> m_parentConnections;

    NSView *m_containerView = nullptr;
    NSImageView *m_imageView = nullptr;

    QUrl m_lastSource;
    QSize m_lastPixelSize;
};

NativeIndicatorNative_macOS::NativeIndicatorNative_macOS(QQuickItem *parent)
    : NativeIndicatorNative(parent)
{
    connect(this, &NativeIndicatorNative::sourceChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::visibleChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::enabledChanged, this, [this]() { polish(); });
    QTimer::singleShot(0, this, [this]() { polish(); });
}

NativeIndicatorNative_macOS::~NativeIndicatorNative_macOS()
{
    detachParentWatchers();
    destroyViews();
}

NSView *NativeIndicatorNative_macOS::getNSView() const
{
    if (!window())
        return nullptr;
    return reinterpret_cast<NSView *>(window()->winId());
}

void NativeIndicatorNative_macOS::ensureViews()
{
    if (m_containerView && m_imageView)
        return;

    NSView *root = getNSView();
    if (!root)
        return;

    m_containerView = [[NSView alloc] initWithFrame:NSZeroRect];
    m_containerView.wantsLayer = YES;
    m_containerView.layer.masksToBounds = NO;
    m_containerView.hidden = YES;

    m_imageView = [[NSImageView alloc] initWithFrame:NSZeroRect];
    m_imageView.imageScaling = NSImageScaleAxesIndependently;
    m_imageView.hidden = YES;

    [m_containerView addSubview:m_imageView];
    [root addSubview:m_containerView];
}

void NativeIndicatorNative_macOS::destroyViews()
{
    if (m_imageView) {
        [m_imageView removeFromSuperview];
        [m_imageView release];
        m_imageView = nullptr;
    }
    if (m_containerView) {
        [m_containerView removeFromSuperview];
        [m_containerView release];
        m_containerView = nullptr;
    }
}

void NativeIndicatorNative_macOS::attachParentWatchers()
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

void NativeIndicatorNative_macOS::detachParentWatchers()
{
    for (const auto &c : std::as_const(m_parentConnections))
        disconnect(c);
    m_parentConnections.clear();
    m_parentItem.clear();
}

void NativeIndicatorNative_macOS::itemChange(ItemChange change, const ItemChangeData &value)
{
    QQuickItem::itemChange(change, value);
    if (change == ItemSceneChange) {
        if (value.window) QTimer::singleShot(0, this, [this]() { polish(); });
        else { detachParentWatchers(); destroyViews(); }
    } else if (change == ItemParentHasChanged) {
        attachParentWatchers();
        polish();
    }
}

void NativeIndicatorNative_macOS::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    Q_UNUSED(oldGeometry)
    polish();
}

void NativeIndicatorNative_macOS::updatePolish()
{
    QQuickItem::updatePolish();
    syncToNative();
}

void NativeIndicatorNative_macOS::syncToNative()
{
    if (!window() || !isVisible() || !isEnabled()) {
        if (m_containerView) m_containerView.hidden = YES;
        if (m_imageView) m_imageView.hidden = YES;
        return;
    }

    ensureViews();
    attachParentWatchers();
    updateImageIfNeeded();
    updateFramesAndVisibility();
}

void NativeIndicatorNative_macOS::updateImageIfNeeded()
{
    if (!m_imageView)
        return;

    const QUrl src = source();
    if (src.isEmpty())
        return;

    const qreal dpr = window() ? window()->effectiveDevicePixelRatio() : 1.0;
    const QSize pixelSize(qMax(1, int(width() * dpr)), qMax(1, int(height() * dpr)));
    if (src == m_lastSource && pixelSize == m_lastPixelSize && m_imageView.image != nil)
        return;

    QString path;
    if (src.isLocalFile()) {
        path = src.toLocalFile();
    } else if (src.scheme() == QLatin1String("qrc")) {
        path = QLatin1Char(':') + src.path();
    } else {
        path = src.toString();
    }

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

    NSData *data = [NSData dataWithBytes:png.constData() length:png.size()];
    NSImage *nsImg = [[NSImage alloc] initWithData:data];
    if (nsImg) {
        [m_imageView setImage:nsImg];
        [nsImg release];
        m_lastSource = src;
        m_lastPixelSize = pixelSize;
    }
}

void NativeIndicatorNative_macOS::updateFramesAndVisibility()
{
    if (!m_containerView || !m_imageView || !window())
        return;

    QQuickItem *pItem = parentItem();
    const bool parentClips = pItem ? pItem->clip() : false;

    QPointF parentScenePos(0, 0);
    QSizeF parentSize(0, 0);
    if (pItem) {
        parentScenePos = pItem->mapToScene(QPointF(0, 0));
        parentSize = QSizeF(pItem->width(), pItem->height());
    } else {
        parentSize = QSizeF(window()->width(), window()->height());
    }

    QPointF indicatorScenePos = mapToScene(QPointF(0, 0));
    const qreal localX = indicatorScenePos.x() - parentScenePos.x();
    const qreal localY = indicatorScenePos.y() - parentScenePos.y();

    NSView *root = getNSView();
    if (!root)
        return;

    const CGFloat rootH = root.frame.size.height;
    const CGFloat containerX = parentScenePos.x();
    const CGFloat containerY = rootH - parentScenePos.y() - parentSize.height();
    const CGFloat containerW = parentSize.width();
    const CGFloat containerH = parentSize.height();

    m_containerView.frame = NSMakeRect(containerX, containerY, containerW, containerH);
    m_containerView.layer.masksToBounds = parentClips ? YES : NO;

    const CGFloat imgX = localX;
    const CGFloat imgY = containerH - localY - height();
    m_imageView.frame = NSMakeRect(imgX, imgY, width(), height());

    const bool show = isVisible() && isEnabled();
    m_containerView.hidden = !show;
    m_imageView.hidden = !show;
}

void registerNativeIndicatorNativeType()
{
    qmlRegisterType<NativeIndicatorNative_macOS>("StatusQ.Controls", 0, 1, "NativeIndicatorNative");
}

#include "NativeIndicatorNative_macos.moc"

#endif // Q_OS_MACOS


