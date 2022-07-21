#pragma once

#include "helpers.h"

#include <QString>
#include <QByteArray>
#include <QColor>
#include <QUrl>

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

using namespace std::string_literals;

template<>
struct adl_serializer<QByteArray> {
    static void to_json(json& j, const QByteArray& data) {
        j = data.toStdString();
    }

    static void from_json(const json& j, QByteArray& data) {
        auto str = j.get<std::string>();
        if(str.size() >= 2 && Status::Helpers::iequals(str, "0x"s, 2))
            data = QByteArray::fromHex(QByteArray::fromRawData(str.c_str() + 2 * sizeof(str[0]), str.size() - 2));
        else
            data = QByteArray::fromStdString(str);
    }
};

template<>
struct adl_serializer<QColor> {
    static void to_json(json& j, const QColor& color) {
        j = color.name();
    }

    static void from_json(const json& j, QColor& color) {
        color = QColor(QString::fromStdString(j.get<std::string>()));
    }
};

template<>
struct adl_serializer<QUrl> {
    static void to_json(json& j, const QUrl& url) {
        j = url.toString();
    }

    static void from_json(const json& j, QUrl& url) {
        url = QUrl(QString::fromStdString(j.get<std::string>()));
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
