#include "Status/Wallet/SavedAddressesController.h"
#include "Helpers/helpers.h"

namespace Status::Wallet
{

SavedAddressesController::SavedAddressesController(QObject* parent)
    : QObject(parent)
    , m_savedAddresses(Helpers::makeSharedQObject<SavedAddressesModel>(
          /* TODO: std::move(getWalletAccounts()), */"savedAddress"))
{
}

QAbstractListModel* SavedAddressesController::savedAddresses() const
{
    return m_savedAddresses.get();
}

void SavedAddressesController::saveAddress(const QString &address, const QString &name)
{
//    TODO: check present addresses
//    {
//        emit error(AddressAlreadyPresentError);
//        return;
//    }

    auto item = Helpers::makeSharedQObject<SavedAddress>(address, name);
    m_savedAddresses->push_back(item);
}

} // namespace Status::Wallet
