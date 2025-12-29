#include <StatusQ/NativeSwipeHandlerNative.h>

#ifdef Q_OS_IOS

#import <UIKit/UIKit.h>

#include <QQuickWindow>
#include <QTimer>

class NativeSwipeHandlerNative_iOS;

@interface NativeSwipePanTarget : NSObject <UIGestureRecognizerDelegate>
@property (nonatomic, assign) NativeSwipeHandlerNative_iOS *handler;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
@end

class NativeSwipeHandlerNative_iOS : public NativeSwipeHandlerNative
{
    Q_OBJECT

public:
    explicit NativeSwipeHandlerNative_iOS(QQuickItem *parent = nullptr);
    ~NativeSwipeHandlerNative_iOS() override;

    void handlePanBegan(qreal translationX, qreal velocityX);
    void handlePanChanged(qreal translationX, qreal velocityX);
    void handlePanEnded(qreal translationX, qreal velocityX);

protected:
    void setupGestureRecognition() override;
    void teardownGestureRecognition() override;
    void itemChange(ItemChange change, const ItemChangeData &value) override;

private:
    UIView *getUIView() const;
    void maybeUpdateCachedOpenDistance();
    qreal effectiveOpenDistance() const { return openDistance() > 0.0 ? openDistance() : (m_cachedOpenDistance > 1.0 ? m_cachedOpenDistance : 280.0); }

    UIPanGestureRecognizer *m_pan = nullptr;
    NativeSwipePanTarget *m_target = nullptr;
    bool m_attached = false;

    bool m_active = false;
    qreal m_startTranslationX = 0.0;
    qreal m_from = 0.0;
    qreal m_to = 1.0;
    qreal m_cachedOpenDistance = 0.0;
};

NativeSwipeHandlerNative_iOS::NativeSwipeHandlerNative_iOS(QQuickItem *parent)
    : NativeSwipeHandlerNative(parent)
{
    QTimer::singleShot(0, this, [this]() { setupGestureRecognition(); });
}

NativeSwipeHandlerNative_iOS::~NativeSwipeHandlerNative_iOS()
{
    teardownGestureRecognition();
}

UIView *NativeSwipeHandlerNative_iOS::getUIView() const
{
    if (!window()) return nullptr;
    return reinterpret_cast<UIView *>(window()->winId());
}

void NativeSwipeHandlerNative_iOS::maybeUpdateCachedOpenDistance()
{
    if (!m_active && x() > 1.0)
        m_cachedOpenDistance = x();
}

void NativeSwipeHandlerNative_iOS::setupGestureRecognition()
{
    if (m_attached) return;
    UIView *view = getUIView();
    if (!view) return;

    m_target = [[NativeSwipePanTarget alloc] init];
    [m_target setHandler:this];

    m_pan = [[UIPanGestureRecognizer alloc] initWithTarget:m_target action:@selector(handlePan:)];
    m_pan.maximumNumberOfTouches = 1;
    m_pan.delegate = m_target;
    [view addGestureRecognizer:m_pan];

    m_attached = true;
}

void NativeSwipeHandlerNative_iOS::teardownGestureRecognition()
{
    if (!m_attached) return;
    UIView *view = getUIView();
    if (view && m_pan) {
        [view removeGestureRecognizer:m_pan];
        [m_pan release];
        m_pan = nullptr;
    }
    if (m_target) {
        [m_target setHandler:nullptr];
        [m_target release];
        m_target = nullptr;
    }
    m_attached = false;
    m_active = false;
}

void NativeSwipeHandlerNative_iOS::itemChange(ItemChange change, const ItemChangeData &value)
{
    NativeSwipeHandlerNative::itemChange(change, value);
    if (change == ItemSceneChange) {
        if (value.window) QTimer::singleShot(0, this, [this]() { setupGestureRecognition(); });
        else teardownGestureRecognition();
    }
}

void NativeSwipeHandlerNative_iOS::handlePanBegan(qreal translationX, qreal /*velocityX*/)
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

void NativeSwipeHandlerNative_iOS::handlePanChanged(qreal translationX, qreal velocityX)
{
    if (!m_active) return;
    const qreal openDist = effectiveOpenDistance();
    const qreal delta = translationX - m_startTranslationX;

    qreal position = 0.0;
    if (m_from < m_to) position = qMax<qreal>(0.0, qMin<qreal>(1.0, delta / openDist));
    else position = qMax<qreal>(0.0, qMin<qreal>(1.0, 1.0 + (delta / openDist)));

    emit swipeProgress(position, m_from, m_to, velocityX);
}

void NativeSwipeHandlerNative_iOS::handlePanEnded(qreal translationX, qreal velocityX)
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

@implementation NativeSwipePanTarget

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NativeSwipeHandlerNative_iOS *handler = self.handler;
    if (!handler || !handler->window() || !handler->isVisible() || !handler->isEnabled())
        return NO;

    UIView *view = gestureRecognizer.view;
    if (!view) return NO;

    CGPoint locationInView = [touch locationInView:view];
    QPointF scenePoint(locationInView.x, view.frame.size.height - locationInView.y);
    QPointF localPoint = handler->mapFromScene(scenePoint);
    return handler->contains(localPoint);
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    NativeSwipeHandlerNative_iOS *handler = self.handler;
    if (!handler || !handler->window() || !handler->isVisible() || !handler->isEnabled())
        return;

    UIView *view = recognizer.view;
    CGPoint translation = [recognizer translationInView:view];
    CGPoint velocity = [recognizer velocityInView:view];

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            handler->handlePanBegan(translation.x, velocity.x);
            break;
        case UIGestureRecognizerStateChanged:
            handler->handlePanChanged(translation.x, velocity.x);
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            handler->handlePanEnded(translation.x, velocity.x);
            break;
        default:
            break;
    }
}

@end

void registerNativeSwipeHandlerNativeType()
{
    qmlRegisterType<NativeSwipeHandlerNative_iOS>("StatusQ.Controls", 0, 1, "NativeSwipeHandlerNative");
}

#include "NativeSwipeHandlerNative_ios.moc"

#endif // Q_OS_IOS


