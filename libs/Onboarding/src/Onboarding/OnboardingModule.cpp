#include "OnboardingModule.h"

#include "Accounts/AccountsService.h"

#include <ApplicationCore/UserConfiguration.h>


namespace AppCore = Status::ApplicationCore;

namespace fs = std::filesystem;

namespace Status::Onboarding {

OnboardingModule::OnboardingModule(const fs::path& userDataPath, QObject *parent)
    : OnboardingModule{parent}
{
    m_userDataPath = userDataPath;
    initWithUserDataPath(m_userDataPath);
}

OnboardingModule::OnboardingModule(QObject *parent)
    : QObject{parent}
    , m_accountsService(std::make_shared<AccountsService>())
{
}

OnboardingController* OnboardingModule::controller() const
{
    return m_controller.get();
}

void OnboardingModule::componentComplete()
{
    try {
        initWithUserDataPath(m_userDataPath);
    } catch(const std::exception &e) {
        qCritical() << "OnboardingModule: failed to initialize";
    }
}

void OnboardingModule::initWithUserDataPath(const fs::path &path)
{
    auto result = m_accountsService->init(path);
    if(!result)
        throw std::runtime_error(std::string("Failed to initialize OnboadingService") + path.string());
    m_controller = std::make_shared<OnboardingController>(
                m_accountsService);
    emit controllerChanged();
}

const QString OnboardingModule::userDataPath() const
{
    return QString::fromStdString(m_userDataPath.string());
}

void OnboardingModule::setUserDataPath(const QString &newUserDataPath)
{
    auto newVal = newUserDataPath.toStdString();
    if (m_userDataPath.compare(newVal) == 0)
        return;
    m_userDataPath = newVal;
    emit userDataPathChanged();
}

}
