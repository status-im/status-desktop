#ifndef STATUS_SOUND_MANAGER_H
#define STATUS_SOUND_MANAGER_H

#include <QObject>
#include <QMediaPlayer>
#include <memory>

namespace Status
{
    class SoundManager : public QObject
    {
        Q_OBJECT

    public:
        /*!
         * Singleton instance.
         */
        static SoundManager &instance();

        /*!
         * Delete copy constructor.
         */
        SoundManager(const SoundManager &) = delete;
        /*!
         * Delete move constructor.
         */
        SoundManager(SoundManager &&) = delete;
        /*!
         * Delete copy asignment operator.
         */
        SoundManager &operator=(const SoundManager &) = delete;
        /*!
         * Delete move asignment operator.
         */
        SoundManager &operator=(SoundManager &&) = delete;

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

#endif
