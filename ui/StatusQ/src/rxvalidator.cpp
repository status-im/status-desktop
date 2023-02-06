#include "StatusQ/rxvalidator.h"

RXValidator::RXValidator(QObject* parent)
    : QValidator(parent)
{
}

bool RXValidator::test(QString input) const
{
    int dummy_pos = 0;
    return validate(input, dummy_pos) == QValidator::Acceptable;
}

QRegularExpression RXValidator::regularExpression() const
{
    return m_rx;
}

void RXValidator::setRegularExpression(const QRegularExpression& re)
{
    if (m_rx != re) {
        m_rx = re;
        m_rx.setPatternOptions(re.patternOptions() | QRegularExpression::UseUnicodePropertiesOption);
        m_rx.setPattern(QRegularExpression::anchoredPattern(re.pattern()));
        emit regularExpressionChanged(m_rx);
        emit changed();
    }
}

QValidator::State RXValidator::validate(QString& input, int& pos) const
{
    if (m_rx.pattern().isEmpty())
        return Acceptable;

    const QRegularExpressionMatch m = m_rx.match(input, 0, QRegularExpression::PartialPreferCompleteMatch);
    if (m.hasMatch())
        return Acceptable;

    if (input.isEmpty() || m.hasPartialMatch())
        return Intermediate;

    pos = input.size();
    return Invalid;
}
