#include "StatusGoEvent.h"

namespace Status::StatusGo
{

constexpr auto statusGoEventErrorKey = "error";

void to_json(json& j, const StatusGoEvent& d)
{
    j = {{"type", d.type}, {"event", d.event}};

    if(d.error != std::nullopt) j[statusGoEventErrorKey] = d.error.value();
}

void from_json(const json& j, StatusGoEvent& d)
{
    j.at("type").get_to(d.type);
    j.at("event").get_to(d.event);

    if(j.contains(statusGoEventErrorKey)) j.at(statusGoEventErrorKey).get_to(d.error);
}

}