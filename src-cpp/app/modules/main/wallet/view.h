#ifndef WALLET_VIEW_H
#define WALLET_VIEW_H

#include <QObject>

namespace Modules
{
namespace Main
{
namespace Wallet
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
} // namespace Wallet
} // namespace Main
} // namespace Modules

#endif // WALLET_VIEW_H

