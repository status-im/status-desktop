#include <StatusQ/NativeSwipeHandlerNative.h>

NativeSwipeHandlerNative::NativeSwipeHandlerNative(QQuickItem *parent)
    : QQuickItem(parent)
{
    setAcceptedMouseButtons(Qt::AllButtons);
    setAcceptTouchEvents(true);
    setFlag(QQuickItem::ItemAcceptsInputMethod, true);
}

void NativeSwipeHandlerNative::setOpenDistance(qreal d)
{
    if (qFuzzyCompare(m_openDistance, d))
        return;
    m_openDistance = d;
    emit openDistanceChanged();
}

void NativeSwipeHandlerNative::setupGestureRecognition()
{
    // Default no-op. Platform-specific implementations override.
}

void NativeSwipeHandlerNative::teardownGestureRecognition()
{
    // Default no-op. Platform-specific implementations override.
}


