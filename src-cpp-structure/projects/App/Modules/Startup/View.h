#pragma once

#include "ViewInterface.h"

namespace Status::Modules::Startup
{
    class View final : public QObject
            , public ViewInterface
    {
        Q_OBJECT

        Q_PROPERTY(int appState READ getAppState NOTIFY appStateChanged)

    public:
        explicit View();
        void setDelegate(std::shared_ptr<ViewDelegateInterface> delegate);

        // View Interface
        QObject* getQObject() override;
        void emitLogOut() override;
        void emitStartUpUIRaised() override;
        void setAppState(AppState state) override;
        void load() override;

    public slots:
        int getAppState();

    signals:
        void appStateChanged(int state);
        void logOut();
        void startUpUIRaised();

    private:
        std::shared_ptr<ViewDelegateInterface> m_delegate;
        AppState m_appState;
    };
}
