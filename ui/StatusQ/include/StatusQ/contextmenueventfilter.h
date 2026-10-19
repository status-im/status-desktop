#pragma once

#include <QContextMenuEvent>
#include <QPointer>
#include <QQuickItem>

// TextEdit rewrites context-menu coordinates to the caret. Capture the original
// event before that happens so editor menus can operate on the clicked word.
class ContextMenuEventFilter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem* target READ target WRITE setTarget NOTIFY targetChanged)
public:
    explicit ContextMenuEventFilter(QObject* parent = nullptr) : QObject(parent) {}

    QQuickItem* target() const { return m_target; }
    void setTarget(QQuickItem* target)
    {
        if (target == m_target)
            return;
        if (m_target)
            m_target->removeEventFilter(this);
        m_target = target;
        if (m_target)
            m_target->installEventFilter(this);
        emit targetChanged();
    }

signals:
    void targetChanged();
    void requested(const QPointF& position, bool keyboard);

protected:
    bool eventFilter(QObject* watched, QEvent* event) override
    {
        if (watched != m_target || event->type() != QEvent::ContextMenu)
            return QObject::eventFilter(watched, event);
        const auto* request = static_cast<QContextMenuEvent*>(event);
        emit requested(m_target->mapFromScene(request->pos()),
                       request->reason() == QContextMenuEvent::Keyboard);
        event->accept();
        return true;
    }

private:
    QPointer<QQuickItem> m_target;
};
