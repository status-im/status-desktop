#pragma once

#include <QObject>
#include <QFuture>

#ifdef __OBJC__
#include <LocalAuthentication/LAContext.h>
#else
class LAContext;
#endif

class Keychain : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString service READ service WRITE setService NOTIFY serviceChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit Keychain(QObject *parent = nullptr);
    ~Keychain() override;

    enum Status {
        StatusSuccess = 0,
        StatusNotSupported,
        StatusGenericError,
        StatusUnavailable,
        StatusCancelled,
        StatusNotFound,
    };

    Q_ENUM(Status)

    QString service() const;
    void setService(const QString &service);

    bool loading() const;

    Q_INVOKABLE void requestSaveCredential(const QString &reason, const QString &account, const QString &password);
    Q_INVOKABLE void requestDeleteCredential(const QString &reason, const QString &account);
    Q_INVOKABLE void requestGetCredential(const QString &reason, const QString &account);
    Q_INVOKABLE void cancelActiveRequest();

signals:
    void saveCredentialRequestCompleted(Keychain::Status status);
    void deleteCredentialRequestCompleted(Keychain::Status status);
    void getCredentialRequestCompleted(Keychain::Status status, const QString &password);

    void serviceChanged();
    void reasonChanged();
    void loadingChanged();

private:
    QString m_service;
    QString m_reason;
    bool m_loading = false;
    void setLoading(bool loading);

    QFuture<void> m_future;
    LAContext *m_activeAuthContext;

#ifdef Q_OS_MACOS
    Status saveCredential(const QString &account, const QString &password);
    Status deleteCredential(const QString &account);
    Status getCredential(const QString &account, QString *out);
#endif
};
