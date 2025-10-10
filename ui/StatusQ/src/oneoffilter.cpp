#include "StatusQ/oneoffilter.h"

/*!
    \qmltype OneOfFilter
    \inherits RoleFilter
    \inqmlmodule SortFilterProxyModel
    \ingroup Filters
    \brief Filters rows included in the \p array

    A OneOfFilter is a \l RoleFilter that accepts rows if their data is contained in the \p array property.
    The values in \p array are converted to strings.
    If the \p separator is supplied, the \p array is treated as one string, separated by it.

    \code
    readonly property string filterArray1: "1:10:42" // needs the ":" separator param
    readonly property var filterArray2: ["1", "10", "42"]

    SortFilterProxyModel {
      sourceModel: chainsModel
      filters: OneOfFilter {
        array: filterArray1 // or filterArray2
        separator: ":" // <-- optional
      }
    }
    \encode
*/

OneOfFilter::OneOfFilter(QObject *parent)
    : RoleFilter(parent)
{
}

bool OneOfFilter::filterRow(const QModelIndex& sourceIndex, const qqsfpm::QQmlSortFilterProxyModel& proxyModel) const
{
    const auto strValue = sourceData(sourceIndex, proxyModel).toString();
    return m_actualArray.contains(strValue);
}

void OneOfFilter::proxyModelCompleted(const qqsfpm::QQmlSortFilterProxyModel &proxyModel)
{
    if (roleName().isEmpty()) {
        qWarning() << Q_FUNC_INFO << "Required property 'roleName' is not set";
        return;
    }
    updateActualArray();

    connect(this, &OneOfFilter::paramsChanged, this, &OneOfFilter::updateActualArray);
    connect(this, &OneOfFilter::actualArrayChanged, this, &OneOfFilter::invalidate);
}

QVariant OneOfFilter::array() const
{
    return m_array;
}

void OneOfFilter::setArray(const QVariant &newArray)
{
    if (m_array == newArray)
        return;
    m_array = newArray;
    emit paramsChanged();
}

QString OneOfFilter::separator() const
{
    return m_separator;
}

void OneOfFilter::setSeparator(const QString &newSeparator)
{
    if (m_separator == newSeparator)
        return;
    m_separator = newSeparator;
    emit paramsChanged();
}

QStringList OneOfFilter::actualArray() const
{
    return m_actualArray;
}

void OneOfFilter::updateActualArray()
{
    if (m_array.isNull() || !m_array.isValid()) {
        qWarning() << Q_FUNC_INFO << "Supplied 'array' is null or invalid!" << m_array;
        return;
    }

    m_actualArray.clear();

    if (m_array.canConvert<QString>()) {
        if (m_separator.isEmpty()) {
            qWarning() << Q_FUNC_INFO << "The required separator for a string 'array' is empty!";
            return;
        }
        const auto arrString = m_array.toString();
        m_actualArray = arrString.split(m_separator, Qt::SkipEmptyParts);
    } else if (m_array.canConvert<QStringList>()) {
        m_actualArray = m_array.toStringList();
    } else if (m_array.canConvert<QVariantList>()) {
        const auto varList = m_array.toList();
        m_actualArray.reserve(varList.size());
        for (const auto& varListEntry: varList) {
            m_actualArray.append(varListEntry.toString());
        }
    } else {
        qWarning() << Q_FUNC_INFO << "Don't know how to convert the 'array' to a list type; the type is:" << m_array.metaType().name();
        return;
    }

    emit actualArrayChanged();
}
