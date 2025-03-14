#pragma once

#include <QObject>
#include <QMediaPlayer>

class QJSEngine;
class QQmlEngine;

class AudioUtils : public QObject
{
    Q_OBJECT
public:
    explicit AudioUtils();
    static QObject* qmlInstance(QQmlEngine* engine, QJSEngine* scriptEngine);


    Q_INVOKABLE qreal convertLogarithmicToLinearVolumeScale(qreal volume);
};
