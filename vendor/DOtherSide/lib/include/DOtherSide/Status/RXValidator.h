#pragma once

#include <QValidator>

// A QValidator built around QRegularExpression, but with Unicode support
// (RegularExpressionValidator doesn't expose this to QML)

class RXValidator : public QValidator
{
    Q_OBJECT
    Q_PROPERTY(QRegularExpression regularExpression READ regularExpression WRITE setRegularExpression NOTIFY regularExpressionChanged)

public:
    RXValidator(QObject* parent = nullptr);

    // helper QML function
    Q_INVOKABLE bool test(QString input) const;

protected:
    QValidator::State validate(QString &input, int &pos) const override;

signals:
    void regularExpressionChanged(const QRegularExpression &re);

private:
    QRegularExpression regularExpression() const;
    void setRegularExpression(const QRegularExpression &re);

    QRegularExpression m_rx;
};
