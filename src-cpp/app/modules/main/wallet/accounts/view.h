#ifndef WALLET_ACCOUNT_VIEW_H
#define WALLET_ACCOUNT_VIEW_H

#include <QObject>
#include <memory>

#include "model.h"

namespace Modules::Main::Wallet::Accounts
{
class View : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Model* model READ getModel NOTIFY modelChanged)

public:
    explicit View(QObject* parent = nullptr);
    ~View() = default;

    void load();
    void setModelItems(QVector<Item> &accounts);

private:
    Model* m_modelPtr;

public slots:
    Model* getModel();

signals:
    void viewLoaded();
    void modelChanged();
};
} // namespace Modules::Main::Wallet::Accounts

#endif // WALLET_ACCOUNT_VIEW_H
