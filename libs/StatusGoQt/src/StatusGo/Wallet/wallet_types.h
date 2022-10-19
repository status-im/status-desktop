#include <Helpers/NamedType.h>
#include <Helpers/conversions.h>

#include <nlohmann/json.hpp>

#include <QString>

using json = nlohmann::json;

/// Defines phantom types for strong typing
namespace Status::StatusGo::Wallet
{

using ChainID = Helpers::NamedType<unsigned long long int, struct ChainIDTag>;

}
