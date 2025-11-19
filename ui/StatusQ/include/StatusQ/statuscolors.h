#pragma once

#include <QColor>
#include <QObject>
#include <QVariantMap>

class StatusColors : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap colors READ colors CONSTANT)

public:
    explicit StatusColors(QObject* parent = nullptr);

    static const QVariantMap& colors();

    Q_INVOKABLE static QColor getColor(const QString& name, qreal alpha = -1);
    Q_INVOKABLE static QColor alphaColor(const QColor& color, qreal alpha);
};
