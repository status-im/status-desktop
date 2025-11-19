#pragma once

#include "StatusQ/themepalette.h"

#include <QObject>
#include <QQmlEngine>
#include <QQuickAttachedPropertyPropagator>

class Theme : public QQuickAttachedPropertyPropagator
{
    Q_OBJECT

    Q_PROPERTY(qreal padding READ padding WRITE setPadding RESET resetPadding NOTIFY paddingChanged)
    Q_PROPERTY(qreal xlPadding READ xlPadding NOTIFY paddingChanged)
    Q_PROPERTY(qreal bigPadding READ bigPadding NOTIFY paddingChanged)
    Q_PROPERTY(qreal halfPadding READ halfPadding NOTIFY paddingChanged)
    Q_PROPERTY(qreal smallPadding READ smallPadding NOTIFY paddingChanged)

    Q_PROPERTY(bool explicitPadding READ explicitPadding NOTIFY explicitPaddingChanged)

    Q_PROPERTY(Style style READ style WRITE setStyle RESET resetStyle NOTIFY styleChanged)
    Q_PROPERTY(const ThemePalette* palette READ palette NOTIFY styleChanged)

    Q_PROPERTY(bool explicitStyle READ explicitStyle NOTIFY explicitStyleChanged)

    enum class Style {
        Light,
        Dark
    };

    Q_ENUM(Style)

public:
    explicit Theme(QObject *parent = nullptr);

    qreal padding() const;
    qreal xlPadding() const;
    qreal bigPadding() const;
    qreal halfPadding() const;
    qreal smallPadding() const;

    void setPadding(qreal padding);
    void resetPadding();

    void inheritPadding(qreal padding);
    void propagatePadding();

    bool explicitPadding() const;

    Style style() const;
    void setStyle(Style style);
    void resetStyle();

    void inheritStyle(Style style);
    void propagateStyle();

    bool explicitStyle() const;

    const ThemePalette* palette() const;

    static Theme *qmlAttachedProperties(QObject *object);

signals:
    void paddingChanged();
    void explicitPaddingChanged();

    void explicitStyleChanged();
    void styleChanged();

protected:
    void attachedParentChange(
        QQuickAttachedPropertyPropagator *newParent,
        QQuickAttachedPropertyPropagator *oldParent) override;

private:
    bool m_explicitPadding = false;
    qreal m_padding = 0.0;

    bool m_explicitStyle = false;
    Style m_style = Style::Light;
};

QML_DECLARE_TYPEINFO(Theme, QML_HAS_ATTACHED_PROPERTIES)
