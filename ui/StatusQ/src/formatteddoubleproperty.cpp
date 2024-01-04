#include "StatusQ/formatteddoubleproperty.h"

#include <QDebug>

FormattedDoubleProperty::FormattedDoubleProperty(QObject* parent)
    : QObject{parent}
{
    m_locale.setNumberOptions(QLocale::DefaultNumberOptions | QLocale::OmitGroupSeparator);
}

QVariant FormattedDoubleProperty::value() const
{
    return m_value;
}

void FormattedDoubleProperty::setValue(const QVariant& newValue)
{
    if (!newValue.isValid()) {
        qWarning() << "Setting property to invalid value:" << newValue << "is not supported";
        return;
    }

    auto ok = false;
    auto tempValue = newValue.toDouble(&ok);

    if (!ok && newValue.canConvert<QString>()) {
        tempValue = m_locale.toDouble(newValue.toString(), &ok);
    }

    if (!ok || qIsNaN(tempValue)) {
        qWarning() << "Failed set value property from:" << newValue << "; with type:" << newValue.typeName();
        return;
    }

    if (m_value != tempValue) {
        m_value = tempValue;
        emit valueChanged();
    }
}

QString FormattedDoubleProperty::asString() const
{
    return QString::number(m_value, 'f', QLocale::FloatingPointShortest);
}

QString FormattedDoubleProperty::asLocaleString(int decimals) const
{
    return m_locale.toString(m_value, 'f', decimals);
}

QString FormattedDoubleProperty::locale() const
{
    return m_locale.name();
}

void FormattedDoubleProperty::setLocale(const QString& newLocale)
{
    if (m_locale.name() == newLocale)
        return;

    if (newLocale.isEmpty())
        m_locale = QLocale(); // user default
    else
        m_locale = QLocale(newLocale); // explicit
    emit localeChanged();
}
