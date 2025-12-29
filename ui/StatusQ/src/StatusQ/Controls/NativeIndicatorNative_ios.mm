#include <StatusQ/NativeIndicatorNative.h>

#ifdef Q_OS_IOS

#import <UIKit/UIKit.h>

#include <QBuffer>
#include <QImage>
#include <QPainter>
#include <QPointer>
#include <QQuickWindow>
#include <QSvgRenderer>
#include <QTimer>

class NativeIndicatorNative_iOS : public NativeIndicatorNative
{
    Q_OBJECT

public:
    explicit NativeIndicatorNative_iOS(QQuickItem *parent = nullptr);
    ~NativeIndicatorNative_iOS() override;

protected:
    void syncToNative() override;
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;
    void updatePolish() override;

private:
    UIView *getUIView() const;
    void ensureViews();
    void destroyViews();
    void attachParentWatchers();
    void detachParentWatchers();
    void updateImageIfNeeded();
    void updateFramesAndVisibility();

    QPointer<QQuickItem> m_parentItem;
    QVector<QMetaObject::Connection> m_parentConnections;

    UIView *m_containerView = nullptr;
    UIImageView *m_imageView = nullptr;

    QUrl m_lastSource;
    QSize m_lastPixelSize;
};

NativeIndicatorNative_iOS::NativeIndicatorNative_iOS(QQuickItem *parent)
    : NativeIndicatorNative(parent)
{
    connect(this, &NativeIndicatorNative::sourceChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::visibleChanged, this, [this]() { polish(); });
    connect(this, &QQuickItem::enabledChanged, this, [this]() { polish(); });
    QTimer::singleShot(0, this, [this]() { polish(); });
}

NativeIndicatorNative_iOS::~NativeIndicatorNative_iOS()
{
    detachParentWatchers();
    destroyViews();
}

UIView *NativeIndicatorNative_iOS::getUIView() const
{
    if (!window())
        return nullptr;
    return reinterpret_cast<UIView *>(window()->winId());
}

void NativeIndicatorNative_iOS::ensureViews()
{
    if (m_containerView && m_imageView)
        return;

    UIView *root = getUIView();
    if (!root)
        return;

    m_containerView = [[UIView alloc] initWithFrame:CGRectZero];
    m_containerView.userInteractionEnabled = NO;
    m_containerView.hidden = YES;

    m_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    m_imageView.contentMode = UIViewContentModeScaleToFill;
    m_imageView.hidden = YES;

    [m_containerView addSubview:m_imageView];
    [root addSubview:m_containerView];

    // QtWebView (WKWebView) is a native UIView inserted into the same hierarchy.
    // Ensure our overlay stays above it.
    [root bringSubviewToFront:m_containerView];
}

void NativeIndicatorNative_iOS::destroyViews()
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

void NativeIndicatorNative_iOS::attachParentWatchers()
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

void NativeIndicatorNative_iOS::detachParentWatchers()
{
    for (const auto &c : std::as_const(m_parentConnections))
        disconnect(c);
    m_parentConnections.clear();
    m_parentItem.clear();
}

void NativeIndicatorNative_iOS::itemChange(ItemChange change, const ItemChangeData &value)
{
    NativeIndicatorNative::itemChange(change, value);
    if (change == ItemSceneChange) {
        if (value.window) QTimer::singleShot(0, this, [this]() { polish(); });
        else { detachParentWatchers(); destroyViews(); }
    } else if (change == ItemParentHasChanged) {
        attachParentWatchers();
        polish();
    }
}

void NativeIndicatorNative_iOS::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    NativeIndicatorNative::geometryChange(newGeometry, oldGeometry);
    Q_UNUSED(oldGeometry)
    polish();
}

void NativeIndicatorNative_iOS::updatePolish()
{
    QQuickItem::updatePolish();
    syncToNative();
}

void NativeIndicatorNative_iOS::syncToNative()
{
    if (!window() || !isVisible() || !isEnabled()) {
        if (m_containerView) m_containerView.hidden = YES;
        if (m_imageView) m_imageView.hidden = YES;
        return;
    }

    ensureViews();
    if (m_containerView) {
        UIView *root = getUIView();
        if (root)
            [root bringSubviewToFront:m_containerView];
    }
    attachParentWatchers();
    updateImageIfNeeded();
    updateFramesAndVisibility();
}

void NativeIndicatorNative_iOS::updateImageIfNeeded()
{
    if (!m_imageView || !window())
        return;

    const QUrl src = source();
    if (src.isEmpty())
        return;

    const qreal dpr = window()->effectiveDevicePixelRatio();
    const QSize pixelSize(qMax(1, int(width() * dpr)), qMax(1, int(height() * dpr)));
    if (src == m_lastSource && pixelSize == m_lastPixelSize && m_imageView.image != nil)
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

    NSData *data = [NSData dataWithBytes:png.constData() length:png.size()];
    UIImage *uiImg = [UIImage imageWithData:data scale:1.0];
    if (uiImg) {
        m_imageView.image = uiImg;
        m_lastSource = src;
        m_lastPixelSize = pixelSize;
    }
}

void NativeIndicatorNative_iOS::updateFramesAndVisibility()
{
    if (!m_containerView || !m_imageView || !window())
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

    m_containerView.frame = CGRectMake(parentScenePos.x(), parentScenePos.y(), parentSize.width(), parentSize.height());
    m_containerView.clipsToBounds = clip ? YES : NO;
    m_imageView.frame = CGRectMake(localX, localY, width(), height());

    const bool show = isVisible() && isEnabled() && (!pItem || pItem->isVisible());
    m_containerView.hidden = !show;
    m_imageView.hidden = !show;

    // Keep it on top even if native views (e.g. WKWebView) are re-attached later.
    UIView *root = getUIView();
    if (root)
        [root bringSubviewToFront:m_containerView];
}

void registerNativeIndicatorNativeType()
{
    qmlRegisterType<NativeIndicatorNative_iOS>("StatusQ.Controls", 0, 1, "NativeIndicatorNative");
}

#include "NativeIndicatorNative_ios.moc"

#endif // Q_OS_IOS


