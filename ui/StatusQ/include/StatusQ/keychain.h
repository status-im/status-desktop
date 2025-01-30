#pragma once
#include <QObject>

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

    Q_INVOKABLE bool saveCredential(const QString &account, const QString &password);
    Q_INVOKABLE bool deleteCredential(const QString &account);
    Q_INVOKABLE QString getCredential(const QString &account);

signals:
    void serviceChanged();
    void reasonChanged();
    void loadingChanged();

private:
    QString m_service;
    QString m_reason;
    bool m_loading;
    void setLoading(bool loading);
};
