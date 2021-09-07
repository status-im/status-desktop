#ifndef KEYCHAIN_MANAGER_H
#define KEYCHAIN_MANAGER_H

#include "Keychain.h"
#include "LocalAuthentication.h"

namespace Status
{
    class KeychainManager : public QObject
    {
        Q_OBJECT

    public:

        /*!
         * Constructor defining name of the service for storing in the Keychain
         * and the reason for requesting authorisation via touch id.
         *
         * @param service Service name used in Keychain.
         * @param authenticationReason Reason for requestion touch id authorization.
         */
        KeychainManager(const QString& service, 
        const QString& authenticationReason, QObject* parent = nullptr);

        /*!
         * Synchronously reads @data stored in the Keychain under the @key and 
         * returns stored @data. In case of any error an empty string will be
         * returned and error signal will be emitted.
         *
         * @param key Key which is stored in the Keychain.
         */
        QString readDataSync(const QString& key) const;

        /*!
         * Asynchronously reads @data stored in the Keychain under the @key. 
         * Onces it's read success signal will be emitted containing read data, 
         * otherwise error signal will be emitted.
         *
         * @param key Key which is stored in the Keychain.
         */ 
        void readDataAsync(const QString& key);
        /*!
         * Asynchronously stores @data under the @key in the Keychain. 
         * Onces @data is stored success signal will be emitted, otherwise error 
         * signal will be emitted.
         *
         * @param key Key which is stored in the Keychain.
         * @param data Data which is stored in the Keychain.
         */ 
        void storeDataAsync(const QString& key, const QString& data);
        /*!
         * Asynchronously deletes @data stored in the Keychain under the @key. 
         * Onces it's deleted success signal will be emitted, otherwise error 
         * signal will be emitted.
         *
         * @param key Key which is stored in the Keychain.
         */ 
        void deleteDataAsync(const QString& key);

    signals:
        /*!
         * Notifies that action was performed successfully and in case of asyc 
         * read contains read @data, in other cases @data param is empty.
         *
         * @param data Data read from the Keychain.
         */
        void success(QString data);
        /*!
         * Notifies that an error with @error code and @errorString description
         * occured.
         * 
         * @param type Determins origin of the error ("authentication" or "keychain")
         * @param code Error code.
         * @param errorString Error description.
         */
        void error(QString type, int code, const QString& errorString);

#ifdef Q_OS_MACOS
    private:
        void process(const std::function<void()> action);

        QString readDataSyncMacOs(const QString& key) const;
        void readDataAsyncMacOs(const QString& key);
        void storeDataAsyncMacOs(const QString& key, const QString& data);
        void deleteDataAsyncMacOs(const QString& key);

    private:
        QString m_authenticationReason;
        std::unique_ptr<LocalAuthentication> m_localAuth;
        std::unique_ptr<Keychain> m_keychain;
        QMetaObject::Connection m_actionConnection;
#endif
    };
}

#endif
