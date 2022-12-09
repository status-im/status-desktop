#pragma once

#include <QObject>
#include <QMediaPlayer>
#include <memory>

namespace Status
{
    class SoundManager : public QObject
    {
        Q_OBJECT
        Q_DISABLE_COPY_MOVE(SoundManager)
    public:
        /*!
         * Singleton instance.
         */
        static SoundManager &instance();

        /*!
         * Plays a sound with soundUrl.
         *
         * @param soundUrl Url of the sound to play.
         */
        void playSound(const QUrl &soundUrl);
        /*!
         * Sets a volume.
         *
         * @param volume Volume in range 0 - 100.
         */
        void setPlayerVolume(int volume);
        /*!
         * Stops playing, and resets the play position to the beginning.
         */
        void stopPlayer();

    private:
        /*!
         * Constructor.
         */
        SoundManager();

        std::unique_ptr<QMediaPlayer> m_player;
    };
}
