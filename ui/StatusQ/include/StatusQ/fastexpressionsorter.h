#pragma once

#include <sorters/sorter.h>

#include <QQmlContext>
#include <QQmlExpression>
#include <QQmlScriptString>

#include <memory>

class FastExpressionSorter : public qqsfpm::Sorter
{
    Q_OBJECT
    Q_PROPERTY(QQmlScriptString expression READ expression
               WRITE setExpression NOTIFY expressionChanged)

    Q_PROPERTY(QStringList expectedRoles READ expectedRoles
               WRITE setExpectedRoles NOTIFY expectedRolesChanged)
public:
    using qqsfpm::Sorter::Sorter;

    const QQmlScriptString& expression() const;
    void setExpression(const QQmlScriptString& scriptString);

    void proxyModelCompleted(const qqsfpm::QQmlSortFilterProxyModel& proxyModel) override;

    void setExpectedRoles(const QStringList& expectedRoles);
    const QStringList& expectedRoles() const;

Q_SIGNALS:
    void expressionChanged();
    void expectedRolesChanged();

protected:
    int compare(const QModelIndex& sourceLeft, const QModelIndex& sourceRight,
                const qqsfpm::QQmlSortFilterProxyModel& proxyModel) const override;

private:
    void updateContext(const qqsfpm::QQmlSortFilterProxyModel& proxyModel);
    void updateExpression();

    QQmlScriptString m_scriptString;

    std::unique_ptr<QQmlExpression> m_expression;
    std::unique_ptr<QQmlContext> m_context;

    QStringList m_expectedRoles;
};
