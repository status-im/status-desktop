#pragma once

#include <StatusGo/ChatAPI>

#include <QtCore/QtCore>

namespace Status::ChatSection {

    class ChatItem: public QObject
    {
        Q_OBJECT

        Q_PROPERTY(QString id READ id CONSTANT)
        Q_PROPERTY(QString name READ name NOTIFY nameChanged)
        Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
        Q_PROPERTY(QColor color READ color NOTIFY colorChanged)
        Q_PROPERTY(bool muted READ muted NOTIFY mutedChanged)
        Q_PROPERTY(bool active READ active NOTIFY activeChanged)

    public:
        explicit ChatItem(StatusGo::Chats::ChatDto rawData);

        [[nodiscard]] QString id() const;

        [[nodiscard]] QString name() const;
        void setName(const QString& value);

        [[nodiscard]] QString description() const;
        void setDescription(const QString& value);

        [[nodiscard]] QColor color() const;
        void setColor(const QColor& value);

        [[nodiscard]] bool muted() const;
        void setMuted(bool value);

        [[nodiscard]] bool active() const;
        void setActive(bool value);

    signals:
        void nameChanged();
        void descriptionChanged();
        void colorChanged();
        void mutedChanged();
        void activeChanged();

    private:
        StatusGo::Chats::ChatDto m_data;
    };

    using ChatItemPtr = std::shared_ptr<ChatItem>;
}
