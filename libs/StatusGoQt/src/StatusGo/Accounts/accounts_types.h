#include <Helpers/NamedType.h>

#include <nlohmann/json.hpp>

#include <QString>

using json = nlohmann::json;

/// Defines phantom types for strong typing
namespace Status::StatusGo::Accounts {

/// The 20 byte address of an Ethereum account prefixed with 0x
using EOAddress = Helpers::NamedType<QString, struct EOAddressTag>;
using DerivationPath = Helpers::NamedType<QString, struct DerivationPathTag>;

}
