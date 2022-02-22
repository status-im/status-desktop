#pragma once

#include <QObject>

namespace Modules::Main::Wallet
{
class View : public QObject
{
    Q_OBJECT

public:
    explicit View(QObject* parent = nullptr);

    void load();

signals:
    void viewLoaded();
};
} // namespace Modules::Main::Wallet
