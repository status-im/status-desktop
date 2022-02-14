#ifndef WALLET_ACCOUNT_VIEW_H
#define WALLET_ACCOUNT_VIEW_H

#include <QObject>
#include <memory>

#include "model.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
class View : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Model* accountsModel READ getModel NOTIFY modelChanged)

public:
    explicit View(QObject* parent = nullptr);
    ~View() = default;

    void load();
    void setModelItems(QVector<Item> &accounts);

private:
    std::shared_ptr<Model> m_modelPtr;

public slots:
    Model* getModel();

signals:
    void viewLoaded();
    void modelChanged();
};
} // namespace Accounts
} // namespace Wallet
} // namespace Main
} // namespace Modules

#endif // WALLET_ACCOUNT_VIEW_H
