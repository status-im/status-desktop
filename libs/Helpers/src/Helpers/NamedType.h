#pragma once

#include <nlohmann/json.hpp>

#include <type_traits>
#include <utility>

using json = nlohmann::json;

namespace Status::Helpers {

template<typename T>
using IsNotReference = typename std::enable_if<!std::is_reference<T>::value, void>::type;

/// Featureless version of https://github.com/joboccara/NamedType that works with nlohmann::json
template <typename T, typename Parameter>
class NamedType
{
public:
    using UnderlyingType = T;

    // constructor
    explicit constexpr NamedType(T const& value) : m_value(value) {}
    template<typename T_ = T, typename = IsNotReference<T_>>
    explicit constexpr NamedType(T&& value) : m_value(std::move(value)) {}
    explicit constexpr NamedType() = default;

    // get
    constexpr T& get() { return m_value; }
    constexpr std::remove_reference_t<T> const& get() const {return m_value; }

    bool operator<(const NamedType<T, Parameter> &) const = default;
    bool operator>(const NamedType<T, Parameter> &) const = default;
    bool operator<=(const NamedType<T, Parameter> &) const = default;
    bool operator>=(const NamedType<T, Parameter> &) const = default;
    bool operator==(const NamedType<T, Parameter> &) const = default;
    bool operator!=(const NamedType<T, Parameter> &) const = default;

private:
    T m_value;
};

template <typename T, typename P>
void to_json(json& j, const NamedType<T, P>& p) {
    j = p.get();
}

template <typename T, typename P>
void from_json(const json& j, NamedType<T, P>& p) {
    p = NamedType<T, P>{j.get<T>()};
}

}

namespace std
{

template <typename T, typename Parameter>
struct hash<Status::Helpers::NamedType<T, Parameter>>
{
    using NamedType = Status::Helpers::NamedType<T, Parameter>;
    using checkIfHashable = typename std::enable_if<NamedType::is_hashable, void>::type;

    size_t operator()(NamedType const& x) const
    {
        return std::hash<T>()(x.get());
    }
};

}
