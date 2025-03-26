#pragma once

#include <QObject>

class AudioUtils : public QObject
{
    Q_OBJECT
public:
    explicit AudioUtils(QObject *parent = nullptr);

    Q_INVOKABLE qreal convertLogarithmicToLinearVolumeScale(qreal volume) const;
};
