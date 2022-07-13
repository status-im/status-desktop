#pragma once


#include <QString>
#include <QColor>

#include <filesystem>

#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace Status {

QString toQString(const std::filesystem::path& path);

std::filesystem::path toPath(const QString& pathStr);

} // namespace Status

namespace nlohmann {

template<>
struct adl_serializer<QString> {
    static void to_json(json& j, const QString& str) {
        j = str.toStdString();
    }

    static void from_json(const json& j, QString& str) {
        str = QString::fromStdString(j.get<std::string>());
    }
};

template<>
struct adl_serializer<QColor> {
    static void to_json(json& j, const QColor& color) {
        j = color.name();
    }

    static void from_json(const json& j, QColor& color) {
        color = QColor(Status::toQString(j.get<std::string>()));
    }
};

template<typename T>
struct adl_serializer<std::optional<T>> {
    static void to_json(json& j, const std::optional<T>& opt) {
        j = opt.value();
    }

    static void from_json(const json& j, std::optional<T>& opt) {
        opt.emplace(j.get<T>());
    }
};

} // namespace nlohmann
