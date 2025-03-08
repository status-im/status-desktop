#pragma once

#include <QAudio>
#include <QObject>

class QJSEngine;
class QQmlEngine;

class AudioUtils : public QObject {
    Q_OBJECT
public:
    explicit AudioUtils(QObject *parent = nullptr);

    Q_INVOKABLE qreal convertLogarithmicToLinearVolumeScale(qreal volume);
};
