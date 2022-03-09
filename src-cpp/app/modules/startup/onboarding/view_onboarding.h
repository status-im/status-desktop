#pragma once

#include "interfaces/module_view_delegate_interface.h"
#include "model_onboarding.h"
#include <QObject>
#include <QString>
#include <memory>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{

class View : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Model* accountsModel READ getModel NOTIFY modelChanged)
    Q_PROPERTY(QString importedAccountIdenticon READ getImportedAccountIdenticon NOTIFY importedAccountChanged)
    Q_PROPERTY(QString importedAccountAlias READ getImportedAccountAlias NOTIFY importedAccountChanged)
    Q_PROPERTY(QString importedAccountAddress READ getImportedAccountAddress NOTIFY importedAccountChanged)

public:
    explicit View(ModuleViewDelegateInterface* delegate, QObject* parent = nullptr);
    ~View();
    void load();

signals:
    void modelChanged();
    void importedAccountChanged();
    void accountSetupError();
    void accountImportError();

private:
    ModuleViewDelegateInterface* m_delegate;
    Model* m_model;

public slots:
    Model* getModel();
    void setAccountList(QVector<Item> accounts);
    QString getImportedAccountIdenticon();
    QString getImportedAccountAlias();
    QString getImportedAccountAddress();
    void setSelectedAccountByIndex(int index);
    void storeSelectedAccountAndLogin(QString password);
    QString validateMnemonic(QString mnemonic);
    void importMnemonic(QString mnemonic);
    void importAccountError();
    void setupAccountError();
    void importAccountSuccess();
};
} // namespace Onboarding
} // namespace Startup
} // namespace Modules
