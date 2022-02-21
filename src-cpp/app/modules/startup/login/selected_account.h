#pragma once

#include "item.h"
#include <QObject>
#include <QString>

namespace Modules
{
namespace Startup
{
namespace Login
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

private:
    Item m_item;

public slots:
    void setSelectedAccountData(Item item);
    QString getName();
    QString getIdenticon();
    QString getKeyUid();
    QString getThumbnailImage();
    QString getLargeImage();
};
} // namespace Login
} // namespace Startup
} // namespace Modules
