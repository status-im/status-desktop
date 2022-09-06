#pragma once

#include <QtQmlIntegration>

#include <Helpers/QObjectVectorModel.h>

#include "SavedAddress.h"

namespace Status::Wallet
{

class SavedAddressesController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("C++ only")

    Q_PROPERTY(QAbstractListModel* savedAddresses READ savedAddresses CONSTANT)

public:
    enum Error
    {
        NoneError,
        UnknownAddressError,
        AddressAlreadyPresentError
    };
    Q_ENUM(Error)

    SavedAddressesController(QObject* parent = nullptr);

    QAbstractListModel* savedAddresses() const;

    Q_INVOKABLE void saveAddress(const QString& address, const QString& name);
    // Q_INVOKABLE void removeAddress(const QString& address);

signals:
    void error(Status::Wallet::SavedAddressesController::Error error);

private:
    using SavedAddressesModel = Helpers::QObjectVectorModel<SavedAddress>;
    std::shared_ptr<SavedAddressesModel> m_savedAddresses;
};

} // namespace Status::Wallet
