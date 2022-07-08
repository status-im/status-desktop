#pragma once

#include "OnboardingController.h"

#include <QObject>
#include <QtQmlIntegration>

#include <filesystem>

namespace fs = std::filesystem;

namespace Status::Onboarding {

class AccountsService;

/*!
 * \brief Provide bootstrap of controllers and corresponding services
 *
 * \warning status-go is a stateful library and having multiple insteances of the same module is undefined behaviour
 * \todo current state is temporary until refactor StatusGo wrapper to match status-go requirements
 * \warning current state all module spawned/controlled objects have C++ ownership this generate the risk of dangling
 *      invalid QML objects after module is destroyed. Consider moving all the ownership into QML after refactoring
 */
class OnboardingModule : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    QML_ELEMENT
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(OnboardingController* controller READ controller NOTIFY controllerChanged)
    Q_PROPERTY(QString userDataPath READ userDataPath WRITE setUserDataPath NOTIFY userDataPathChanged REQUIRED)

public:
    explicit OnboardingModule(const fs::path& userDataPath, QObject *parent = nullptr);
    explicit OnboardingModule(QObject *parent = nullptr);

    OnboardingController* controller() const;

    const QString userDataPath() const;
    void setUserDataPath(const QString &newUserDataPath);

    /// QML inteface
    void classBegin() override {};
    void componentComplete() override;

signals:
    void controllerChanged();
    void userDataPathChanged();

private:

    /// Throws exceptions
    void initWithUserDataPath(const fs::path &path);

    // TODO: plain object after refactoring shared_ptr requirement for now
    std::shared_ptr<AccountsService> m_accountsService;
    std::shared_ptr<OnboardingController> m_controller;

    fs::path m_userDataPath;
};

}
