#pragma once


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
public:
    explicit ApplicationController(QObject *parent = nullptr);

    QObject *statusAccount() const;
    void setStatusAccount(QObject *newStatusAccount);

signals:
    void statusAccountChanged();

private:
    QObject* m_statusAccount{};
};

}
