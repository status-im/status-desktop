#include "Status/Wallet/SavedAddressesController.h"
#include "Helpers/helpers.h"
#include "Metadata/api_response.h"

#include <StatusGo/Wallet/WalletApi.h>

namespace Status::Wallet
{

SavedAddressesController::SavedAddressesController(QObject* parent)
    : QObject(parent)
    , m_savedAddresses(Helpers::makeSharedQObject<SavedAddressesModel>("savedAddress"))
{ }

QAbstractListModel* SavedAddressesController::savedAddresses() const
{
    return m_savedAddresses.get();
}

// TODO: extend with favourite and chain ID
void SavedAddressesController::saveAddress(const QString& address, const QString& name)
{
    try
    {
        StatusGo::Wallet::saveAddress(StatusGo::Wallet::SavedAddress(
            {StatusGo::Accounts::EOAddress(address), name, false, StatusGo::Wallet::ChainID(0)}));
    }
    catch(const StatusGo::CallPrivateRpcError& rpcError)
    {
        qWarning() << "StatusGoQt.saveAddress error: " << rpcError.errorResponse().error.message.c_str();
        emit error(SaveAddressError);
    }

    // TODO: signal from wallet data_source
    this->refresh();
}

void SavedAddressesController::refresh()
{
    std::vector<SavedAddressPtr> savedAddresses;

    try
    {
        for(const auto& address : StatusGo::Wallet::getSavedAddresses())
        {
            savedAddresses.push_back(std::make_shared<SavedAddress>(address.address.get(), address.name));
        }
    }
    catch(const StatusGo::CallPrivateRpcError& rpcError)
    {
        qWarning() << "StatusGoQt.getSavedAddresses error: " << rpcError.errorResponse().error.message.c_str();
        emit error(RetrieveSavedAddressesError);
    }
    m_savedAddresses->reset(savedAddresses);
}

} // namespace Status::Wallet
