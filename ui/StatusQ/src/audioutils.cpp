#include "StatusQ/audioutils.h"

AudioUtils::AudioUtils(QObject *parent) : QObject(parent) {}

qreal AudioUtils::convertLogarithmicToLinearVolumeScale(qreal volume) {
    return QAudio::convertVolume(volume, QAudio::LogarithmicVolumeScale,
                                 QAudio::LinearVolumeScale);
}
