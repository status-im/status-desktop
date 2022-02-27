#pragma once

#include <StatusServices/Accounts/Service.h>
#include <StatusServices/WalletAccounts/Service.h>
#include <StatusServices/Keychain/Service.h>

#include <boost/di.hpp>

namespace Status
{
    using namespace boost::di;

    const auto Injector = make_injector(
                bind<Accounts::ServiceInterface>.to<Accounts::Service>(),
                bind<WalletAccount::ServiceInterface>.to<WalletAccount::Service>(),
                bind<Keychain::ServiceInterface>.to<Keychain::Service>()
                );
}
