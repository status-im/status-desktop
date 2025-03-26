#include "StatusQ/audioutils.h"

#include <QAudio>

AudioUtils::AudioUtils(QObject *parent)
    : QObject(parent)
{}

qreal AudioUtils::convertLogarithmicToLinearVolumeScale(qreal volume) const
{
    return QAudio::convertVolume(volume, QAudio::LogarithmicVolumeScale, QAudio::LinearVolumeScale);
}
