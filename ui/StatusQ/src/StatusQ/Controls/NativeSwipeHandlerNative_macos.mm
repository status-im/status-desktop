#include <StatusQ/NativeSwipeHandlerNative.h>

#ifdef Q_OS_MACOS

#import <AppKit/AppKit.h>

#include <QPointer>
#include <QQuickWindow>
#include <QTimer>

class NativeSwipeHandlerNative_macOS;

@interface NativeSwipeGestureDelegate : NSObject <NSGestureRecognizerDelegate>
@property (nonatomic, assign) NativeSwipeHandlerNative_macOS *handler;
@property (nonatomic, strong) NSPanGestureRecognizer *panGesture;
- (void)handlePanGesture:(NSPanGestureRecognizer *)recognizer;
@end

class NativeSwipeHandlerNative_macOS : public NativeSwipeHandlerNative
{
    Q_OBJECT

public:
    explicit NativeSwipeHandlerNative_macOS(QQuickItem *parent = nullptr);
    ~NativeSwipeHandlerNative_macOS() override;

    bool isPointInHandlerBounds(const QPointF &windowPoint) const;
    void handlePanBegan(qreal translationX, qreal velocityX);
    void handlePanChanged(qreal translationX, qreal velocityX);
    void handlePanEnded(qreal translationX, qreal velocityX);

protected:
    void setupGestureRecognition() override;
    void teardownGestureRecognition() override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;

private:
    NSView *getNSView() const;
    void attachGestureRecognizer();
    void detachGestureRecognizer();
    void maybeUpdateCachedOpenDistance();

    qreal effectiveOpenDistance() const {
        if (openDistance() > 0.0) return openDistance();
        return m_cachedOpenDistance > 1.0 ? m_cachedOpenDistance : 280.0;
    }

    NativeSwipeGestureDelegate *m_delegate = nullptr;
    bool m_attached = false;

    bool m_active = false;
    qreal m_startTranslationX = 0.0;
    qreal m_from = 0.0;
    qreal m_to = 1.0;
    qreal m_cachedOpenDistance = 0.0;
};

NativeSwipeHandlerNative_macOS::NativeSwipeHandlerNative_macOS(QQuickItem *parent)
    : NativeSwipeHandlerNative(parent)
{
    QTimer::singleShot(0, this, [this]() { setupGestureRecognition(); });
}

NativeSwipeHandlerNative_macOS::~NativeSwipeHandlerNative_macOS()
{
    teardownGestureRecognition();
}

NSView *NativeSwipeHandlerNative_macOS::getNSView() const
{
    if (!window())
        return nullptr;
    return reinterpret_cast<NSView *>(window()->winId());
}

bool NativeSwipeHandlerNative_macOS::isPointInHandlerBounds(const QPointF &windowPoint) const
{
    if (!window() || !isVisible() || !isEnabled())
        return false;
    const QPointF itemPoint = mapFromScene(windowPoint);
    return contains(itemPoint);
}

void NativeSwipeHandlerNative_macOS::maybeUpdateCachedOpenDistance()
{
    if (!m_active && x() > 1.0)
        m_cachedOpenDistance = x();
}

void NativeSwipeHandlerNative_macOS::setupGestureRecognition()
{
    if (m_attached || !window())
        return;
    attachGestureRecognizer();
}

void NativeSwipeHandlerNative_macOS::teardownGestureRecognition()
{
    detachGestureRecognizer();
}

void NativeSwipeHandlerNative_macOS::attachGestureRecognizer()
{
    NSView *view = getNSView();
    if (!view)
        return;

    m_delegate = [[NativeSwipeGestureDelegate alloc] init];
    m_delegate.handler = this;

    NSPanGestureRecognizer *pan = [[NSPanGestureRecognizer alloc] initWithTarget:m_delegate action:@selector(handlePanGesture:)];
    pan.delegate = m_delegate;
    m_delegate.panGesture = pan;
    [view addGestureRecognizer:pan];

    m_attached = true;
}

void NativeSwipeHandlerNative_macOS::detachGestureRecognizer()
{
    if (!m_attached)
        return;

    NSView *view = getNSView();
    if (view && m_delegate && m_delegate.panGesture) {
        [view removeGestureRecognizer:m_delegate.panGesture];
        m_delegate.panGesture = nil;
    }
    if (m_delegate) {
        m_delegate.handler = nullptr;
        [m_delegate release];
        m_delegate = nullptr;
    }

    m_attached = false;
    m_active = false;
}

void NativeSwipeHandlerNative_macOS::handlePanBegan(qreal translationX, qreal /*velocityX*/)
{
    maybeUpdateCachedOpenDistance();
    m_active = true;
    m_startTranslationX = translationX;

    const qreal openDist = effectiveOpenDistance();
    const qreal currentPos = qMax<qreal>(0.0, qMin<qreal>(1.0, x() / openDist));
    if (currentPos >= 0.5) { m_from = 1.0; m_to = 0.0; }
    else { m_from = 0.0; m_to = 1.0; }
    emit swipeStarted(m_from, m_to);
}

void NativeSwipeHandlerNative_macOS::handlePanChanged(qreal translationX, qreal velocityX)
{
    if (!m_active) return;
    const qreal openDist = effectiveOpenDistance();
    const qreal delta = translationX - m_startTranslationX;

    qreal position = 0.0;
    if (m_from < m_to) position = qMax<qreal>(0.0, qMin<qreal>(1.0, delta / openDist));
    else position = qMax<qreal>(0.0, qMin<qreal>(1.0, 1.0 + (delta / openDist)));

    emit swipeProgress(position, m_from, m_to, velocityX);
}

void NativeSwipeHandlerNative_macOS::handlePanEnded(qreal translationX, qreal velocityX)
{
    if (!m_active) return;
    const qreal openDist = effectiveOpenDistance();
    const qreal delta = translationX - m_startTranslationX;
    const bool fast = qAbs(velocityX) > 500.0;
    const bool pastHalf = qAbs(delta) > (openDist * 0.5);
    const bool committed = fast || pastHalf;
    m_active = false;
    emit swipeEnded(committed, m_from, m_to, velocityX);
}

void NativeSwipeHandlerNative_macOS::itemChange(ItemChange change, const ItemChangeData &value)
{
    QQuickItem::itemChange(change, value);
    if (change == ItemSceneChange) {
        if (value.window) QTimer::singleShot(0, this, [this]() { setupGestureRecognition(); });
        else teardownGestureRecognition();
    }
}

@implementation NativeSwipeGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(NSGestureRecognizer *)gestureRecognizer
{
    if (!self.handler || !self.handler->window() || !self.handler->isVisible() || !self.handler->isEnabled())
        return NO;
    NSEvent *event = NSApp.currentEvent;
    if (!event) return NO;

    NSView *view = (NSView *)gestureRecognizer.view;
    if (!view) return NO;

    NSPoint locationInView = [event locationInWindow];
    locationInView = [view convertPoint:locationInView fromView:nil];

    const CGFloat windowH = view.frame.size.height;
    QPointF scenePoint(locationInView.x, windowH - locationInView.y);
    return self.handler->isPointInHandlerBounds(scenePoint);
}

- (void)handlePanGesture:(NSPanGestureRecognizer *)recognizer
{
    if (!self.handler || !self.handler->window() || !self.handler->isVisible() || !self.handler->isEnabled())
        return;

    NSPoint translation = [recognizer translationInView:recognizer.view];
    NSPoint velocity = [recognizer velocityInView:recognizer.view];

    switch (recognizer.state) {
        case NSGestureRecognizerStateBegan:
            self.handler->handlePanBegan(translation.x, velocity.x);
            break;
        case NSGestureRecognizerStateChanged:
            self.handler->handlePanChanged(translation.x, velocity.x);
            break;
        case NSGestureRecognizerStateEnded:
        case NSGestureRecognizerStateCancelled:
            self.handler->handlePanEnded(translation.x, velocity.x);
            break;
        default:
            break;
    }
}

@end

void registerNativeSwipeHandlerNativeType()
{
    qmlRegisterType<NativeSwipeHandlerNative_macOS>("StatusQ.Controls", 0, 1, "NativeSwipeHandlerNative");
}

#include "NativeSwipeHandlerNative_macos.moc"

#endif // Q_OS_MACOS


