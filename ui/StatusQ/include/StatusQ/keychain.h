#pragma once

#include <QObject>
#include <QFuture>

class Keychain : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString service READ service WRITE setService NOTIFY serviceChanged)
    Q_PROPERTY(QString reason READ reason WRITE setReason NOTIFY reasonChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

public:
    explicit Keychain(QObject *parent = nullptr);
    ~Keychain();

    QString service() const;
    void setService(const QString &service);

    QString reason() const;
    void setReason(const QString& reason);

    bool loading() const;

    Q_INVOKABLE void requestSaveCredential(const QString &account, const QString &password);
    Q_INVOKABLE void requestDeleteCredential(const QString &account);
    Q_INVOKABLE void requestGetCredential(const QString &account);

    bool saveCredential(const QString &account, const QString &password);
    bool deleteCredential(const QString &account);
    bool getCredential(const QString &account, QString *out);

signals:
    void saveCredentialRequestCompleted(bool success);
    void deleteCredentialRequestCompleted(bool success);
    void getCredentialRequestCompleted(bool success, const QString& password);

    void serviceChanged();
    void reasonChanged();
    void loadingChanged();

private:
    QString m_service;
    QString m_reason;
    bool m_loading = false;
    void setLoading(bool loading);

    QFuture<void> m_future;
};
