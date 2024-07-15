#pragma once

#include <QValidator>
#include <QQmlScriptString>
#include <QQmlPropertyMap>

#include <memory>

class QQmlExpression;

class GenericValidator : public QValidator
{
    Q_OBJECT

    Q_PROPERTY(QQmlScriptString fixup
               READ fixupScriptString WRITE setFixupScriptString
               NOTIFY fixupScriptStringChanged)

    Q_PROPERTY(QQmlScriptString validate
               READ validateScriptString WRITE setValidateScriptString
               NOTIFY validateScriptStringChanged)

public:
    enum State {
        Invalid = QValidator::Invalid,
        Intermediate = QValidator::Intermediate,
        Acceptable = QValidator::Acceptable
    };
    Q_ENUM(State)

    explicit GenericValidator(QObject* parent = nullptr);

    const QQmlScriptString& fixupScriptString() const;
    void setFixupScriptString(const QQmlScriptString& scriptString);

    const QQmlScriptString& validateScriptString() const;
    void setValidateScriptString(const QQmlScriptString& scriptString);

    void fixup(QString& input) const override;
    QValidator::State validate(QString& input, int& pos) const override;

signals:
    void fixupScriptStringChanged();
    void validateScriptStringChanged();

private:
    bool isValidState(int state) const;

    QQmlScriptString m_fixupScriptString;
    QQmlScriptString m_validateScriptString;

    mutable QQmlPropertyMap m_fixupScope;
    mutable QQmlPropertyMap m_validateScope;

    std::unique_ptr<QQmlExpression> m_fixupExpression;
    std::unique_ptr<QQmlExpression> m_validateExpression;
};
