#include "ChatOrWalletAccount.h"

namespace Status::StatusGo::Accounts {

void to_json(json& j, const ChatOrWalletAccount& d) {
    j = {{"address", d.address},
         {"chat", d.isChat},
         {"clock", d.clock},
         {"color", d.color},
         {"emoji", d.emoji},
         {"hidden", d.isHidden},
         {"mixedcase-address", d.mixedcaseAddress},
         {"name", d.name},
         {"path", d.path},
         {"public-key", d.publicKey},
         {"removed", d.isRemoved},
         {"wallet", d.isWallet},
    };

    if(d.derivedFrom != std::nullopt)
        j["derived-from"] = d.derivedFrom.value();
}

void from_json(const json& j, ChatOrWalletAccount& d) {
    j.at("address").get_to(d.address);
    j.at("chat").get_to(d.isChat);
    j.at("clock").get_to(d.clock);
    j.at("color").get_to(d.color);
    j.at("emoji").get_to(d.emoji);
    j.at("hidden").get_to(d.isHidden);
    j.at("mixedcase-address").get_to(d.mixedcaseAddress);
    j.at("name").get_to(d.name);
    j.at("removed").get_to(d.isRemoved);
    j.at("wallet").get_to(d.isWallet);

    constexpr auto pathKey = "path";
    if(j.contains(pathKey))
        j.at(pathKey).get_to(d.path);
    constexpr auto publicKeyKey = "public-key";
    if(j.contains(publicKeyKey))
        j.at(publicKeyKey).get_to(d.publicKey);
    if(d.isWallet && !j.at("derived-from").get<std::string>().empty())
        d.derivedFrom = j.at("derived-from").get<std::optional<EOAddress>>();
}

}
