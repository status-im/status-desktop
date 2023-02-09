#include "DOtherSide/Status/SoundManager.h"

using namespace Status;

SoundManager &SoundManager::instance()
{
    static SoundManager self;
    return self;
}

SoundManager::SoundManager() : QObject()
{
    m_player.reset(new QMediaPlayer());
}

void SoundManager::playSound(const QUrl &soundUrl)
{
    if (m_player->state() != QMediaPlayer::PlayingState)
    {
        if (m_player->currentMedia().canonicalUrl() != soundUrl)
        {
            m_player->setMedia(soundUrl);
        }

        m_player->play();
    }
}

void SoundManager::setPlayerVolume(int volume)
{
    m_player->setVolume(volume);
}

void SoundManager::stopPlayer()
{
    m_player->stop();
}