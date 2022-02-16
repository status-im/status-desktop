#ifndef WALLET_VIEW_H
#define WALLET_VIEW_H

#include <QObject>

namespace Modules::Main::Wallet
{
class View : public QObject
{
    Q_OBJECT

public:
    explicit View(QObject* parent = nullptr);
    ~View() = default;

    void load();

signals:
    void viewLoaded();
};
} // namespace Modules::Main::Wallet

#endif // WALLET_VIEW_H

