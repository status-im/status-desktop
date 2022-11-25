#pragma once

#include <optional>

#include <QString>

class QAbstractItemModel;

struct ModelUtils
{
    static std::optional<int> findRole(const QByteArray &role,
                                       const QAbstractItemModel *model);
};
