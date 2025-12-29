#pragma once

#include <QQuickItem>

class NativeSwipeHandlerNative : public QQuickItem
{
    Q_OBJECT

    // If > 0, used as the normalization distance for swipe progress (logical units).
    Q_PROPERTY(qreal openDistance READ openDistance WRITE setOpenDistance NOTIFY openDistanceChanged)

public:
    explicit NativeSwipeHandlerNative(QQuickItem *parent = nullptr);
    ~NativeSwipeHandlerNative() override = default;

    qreal openDistance() const { return m_openDistance; }
    void setOpenDistance(qreal d);

signals:
    void openDistanceChanged();

    void swipeStarted(qreal from, qreal to);
    void swipeProgress(qreal position, qreal from, qreal to, qreal velocity);
    void swipeEnded(bool committed, qreal from, qreal to, qreal velocity);

protected:
    virtual void setupGestureRecognition();
    virtual void teardownGestureRecognition();

private:
    qreal m_openDistance = 0.0;
};


