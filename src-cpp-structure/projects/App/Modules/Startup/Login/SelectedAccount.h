#pragma once

#include "Item.h"

#include <QtCore>

namespace Status::Modules::Startup::Login
{
    class SelectedAccount : public QObject
    {
        Q_OBJECT

        Q_PROPERTY(QString username READ getName CONSTANT)
        Q_PROPERTY(QString identicon READ getIdenticon CONSTANT)
        Q_PROPERTY(QString keyUid READ getKeyUid CONSTANT)
        Q_PROPERTY(QString thumbnailImage READ getThumbnailImage CONSTANT)
        Q_PROPERTY(QString largeImage READ getLargeImage CONSTANT)

    public:
        explicit SelectedAccount(QObject* parent = nullptr);

        void setSelectedAccountData(const Item& item);

        QString getName();
        QString getIdenticon();
        QString getKeyUid();
        QString getThumbnailImage();
        QString getLargeImage();

    private:
        Item m_item;
    };
}
