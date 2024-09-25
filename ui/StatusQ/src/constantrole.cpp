#include "StatusQ/constantrole.h"

#include <qqmlsortfilterproxymodel.h>

using namespace qqsfpm;

/*!
    \qmltype ConstantRole
    \inherits SingleRole
    \inqmlmodule StatusQ
    \brief A custom role serving fixed value for all rows.

    \code
    SortFilterProxyModel {
       sourceModel: numberModel
       proxyRoles: ConstantRole {
           name: "type"
           value: "regular"
      }
    }
    \endcode
*/

/*!
    \qmlproperty variant ConstantRole::value

    Value served for all rows for the specified role.
*/
const QVariant& ConstantRole::value() const
{
    return m_value;
}

void ConstantRole::setValue(const QVariant& value)
{
    if (m_value == value)
        return;

    m_value = value;
    emit valueChanged();
    invalidate();
}


QVariant ConstantRole::data(const QModelIndex& sourceIndex,
                            const QQmlSortFilterProxyModel& proxyModel)
{
    Q_UNUSED(sourceIndex)
    Q_UNUSED(proxyModel)

    return m_value;
}
