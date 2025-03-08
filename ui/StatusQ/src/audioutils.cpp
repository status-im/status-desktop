#include "StatusQ/audioutils.h"

AudioUtils::AudioUtils() : QObject()
{
}

QObject* AudioUtils::qmlInstance(QQmlEngine* engine, QJSEngine* scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new AudioUtils;
}

qreal AudioUtils::convertLogarithmicToLinearVolumeScale(qreal volume)
{
    return QAudio::convertVolume(volume,
                                 QAudio::LogarithmicVolumeScale,
                                 QAudio::LinearVolumeScale);
}
