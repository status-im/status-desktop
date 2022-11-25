#include "modelutils.h"

#include <QAbstractItemModel>

std::optional<int> ModelUtils::findRole(const QByteArray &role,
                                        const QAbstractItemModel *model)
{
    if (model == nullptr)
        return std::nullopt;

    const auto roleNames = model->roleNames();

    auto it = std::find_if(roleNames.constKeyValueBegin(),
                           roleNames.constKeyValueEnd(), [&role](auto entry) {
        return entry.second == role;
    });

    return it == roleNames.constKeyValueEnd()
            ? std::nullopt : std::make_optional((*it).first);
}
