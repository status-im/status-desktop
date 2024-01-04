#pragma once

#include <QLocale>

/**
 * @brief The FormattedDoubleProperty class serves as a proxy for numeric inputs in QML
 *
 * It keeps track of its internal `double` value as returns that as a @p value.
 * When setting the @p value, it accepts both a numeric value (int/float/double) or a string
 * representation thereof.
 */
class FormattedDoubleProperty : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged FINAL) //< internal value (double)
    Q_PROPERTY(QString asString READ asString NOTIFY valueChanged FINAL) //< value as a "C" string, `.` as decimal separator
    Q_PROPERTY(QString locale READ locale WRITE setLocale NOTIFY localeChanged FINAL) //< locale name, defaults to user's own
public:
    explicit FormattedDoubleProperty(QObject* parent = nullptr);

    /**
     * @param decimals numbers of decimals to display (defaults to shortest possible)
     * @return @p value formatted according to the selected locale, with the specified number of decimal places
     */
    Q_INVOKABLE QString asLocaleString(int decimals = QLocale::FloatingPointShortest) const;

signals:
    void valueChanged();
    void localeChanged();

private:
    QVariant value() const;
    void setValue(const QVariant& newValue);
    double m_value{0.0};

    QString asString() const;

    QString locale() const;
    void setLocale(const QString& newLocale);
    QLocale m_locale{QLocale()};
};
