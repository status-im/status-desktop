#include <StatusQ/NativeIndicatorNative.h>

NativeIndicatorNative::NativeIndicatorNative(QQuickItem *parent)
    : QQuickItem(parent)
{
    setFlag(QQuickItem::ItemHasContents, false);
}

void NativeIndicatorNative::setSource(const QUrl &source)
{
    if (m_source == source)
        return;
    m_source = source;
    emit sourceChanged();
    syncToNative();
}

void NativeIndicatorNative::syncToNative()
{
    // Default no-op. Platform-specific implementations override.
}


