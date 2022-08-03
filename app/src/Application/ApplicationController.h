#pragma once

#include "DbSettingsObj.h"
#include "DataProvider.h"

#include <QObject>
#include <QtQml/qqmlregistration.h>

// TODO: investigate. This line breaks qobject_cast in OnboardingController::login
//#include <Onboarding/UserAccount.h>

namespace Status::Application {

/**
 * @brief Responsible for providing general information and utility components
 */
class ApplicationController : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QObject* statusAccount READ statusAccount WRITE setStatusAccount NOTIFY statusAccountChanged)
    Q_PROPERTY(QObject* dbSettings READ dbSettings CONSTANT)

public:
    explicit ApplicationController(QObject *parent = nullptr);

    Q_INVOKABLE void initOnLogin();

    QObject *statusAccount() const;
    void setStatusAccount(QObject *newStatusAccount);

    QObject* dbSettings() const;

signals:
    void statusAccountChanged();

private:
    QObject* m_statusAccount{};
    std::unique_ptr<DataProvider> m_dataProvider;
    std::shared_ptr<DbSettingsObj> m_dbSettings;
};

}
