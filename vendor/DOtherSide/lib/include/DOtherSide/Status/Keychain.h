#ifndef KEYCHAIN_H
#define KEYCHAIN_H

#include <QObject>

namespace Status
{
    class Keychain : public QObject
    {
        Q_OBJECT

    public:

        enum Error {
            NoError=0,
            EntryNotFound,
            CouldNotDeleteEntry,
            AccessDeniedByUser,
            AccessDenied,
            NoBackendAvailable,
            NotImplemented,
            OtherError
        };

        Keychain(const QString& service, QObject *parent = nullptr);

        void readItem(const QString& key);
        void writeItem(const QString& key, const QString& data);
        void deleteItem(const QString& key);

    signals:
        void success(QString data);
        void error(int error, const QString& errorString);

    private:
        QString m_service;
    };
}

#endif
