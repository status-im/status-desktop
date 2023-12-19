#include "StatusQ/fastexpressionrole.h"

#include "qqmlsortfilterproxymodel.h"

#include <QQmlContext>
#include <QQmlExpression>

using namespace qqsfpm;

/*!
    \qmltype FastExpressionRole
    \inherits SingleRole
    \inqmlmodule StatusQ
    \brief A custom role similar to (and based on) SFPM's ExpressionRole but
    optimized to access only explicitly indicated roles.

    A FastExpressionRole, similarly as \l ExpressionRole, is a \l ProxyRole
    allowing to implement a custom role based on a javascript expression.
    However in FastExpressionRole's expression context there are available only
    roles explicitly listed in \l expectedRoles property:

    \code
    SortFilterProxyModel {
       sourceModel: numberModel
       proxyRoles: FastExpressionRole {
           name: "c"
           expression: model.a + model.b
           expectedRoles: ["a", "b"]
      }
    }
    \endcode

    By accessing only needed roles, the performance is significantly better in
    comparison to ExpressionRole, especially when the model has multiple
    FastExpressionRole's.
*/

/*!
    \qmlproperty expression FastExpressionRole::expression

    See ExpressionRole::expression for details. Unline the original
    ExpressionRole only roles explicitly declared via expectedRoles are accessible.
*/
const QQmlScriptString& FastExpressionRole::expression() const
{
    return m_scriptString;
}

void FastExpressionRole::setExpression(const QQmlScriptString& scriptString)
{
    if (m_scriptString == scriptString)
        return;

    m_scriptString = scriptString;
    updateExpression();

    emit expressionChanged();
    invalidate();
}

void FastExpressionRole::proxyModelCompleted(const QQmlSortFilterProxyModel& proxyModel)
{
    updateContext(proxyModel);
}

void FastExpressionRole::setExpectedRoles(const QStringList& expectedRoles)
{
    if (m_expectedRoles == expectedRoles)
        return;

    m_expectedRoles = expectedRoles;
    emit expectedRolesChanged();

    invalidate();
}

/*!
    \qmlproperty list<string> FastExpressionRole::expectedRoles

    List of role names intended to be available in the expression's context.
*/
const QStringList& FastExpressionRole::expectedRoles() const
{
    return m_expectedRoles;
}

QVariant FastExpressionRole::data(const QModelIndex& sourceIndex,
                                  const QQmlSortFilterProxyModel& proxyModel)
{
    if (m_scriptString.isEmpty())
        return {};

    QVariantMap modelMap;
    auto roles = proxyModel.roleNames();

    QQmlContext context(qmlContext(this));
    auto addToContext = [&] (const QString &name, const QVariant& value) {
        context.setContextProperty(name, value);
        modelMap.insert(name, value);
    };

    for (auto it = roles.cbegin(); it != roles.cend(); ++it) {
        auto name = it.value();

        if (!m_expectedRoles.contains(name))
            continue;

        addToContext(name, proxyModel.sourceData(sourceIndex, it.key()));
    }

    addToContext(QStringLiteral("index"), sourceIndex.row());

    context.setContextProperty(QStringLiteral("model"), modelMap);

    QQmlExpression expression(m_scriptString, &context);
    QVariant result = expression.evaluate();

    if (expression.hasError())
        qWarning() << expression.error();

    return result;
}

void FastExpressionRole::updateContext(const QQmlSortFilterProxyModel& proxyModel)
{
    delete m_context;
    m_context = new QQmlContext(qmlContext(this), this);

    QVariantMap modelMap;

    auto addToContext = [&] (const QString &name, const QVariant& value) {
        m_context->setContextProperty(name, value);
        modelMap.insert(name, value);
    };

    const auto roles = proxyModel.roleNames();

    for (auto it = roles.cbegin(); it != roles.cend(); ++it) {
        auto name = it.value();

        if (!m_expectedRoles.contains(name))
            continue;

        addToContext(name, {});
    }

    addToContext(QStringLiteral("index"), -1);

    m_context->setContextProperty(QStringLiteral("model"), modelMap);
    updateExpression();
}

void FastExpressionRole::updateExpression()
{
    if (!m_context)
        return;

    delete m_expression;
    m_expression = new QQmlExpression(m_scriptString, m_context, nullptr, this);
    connect(m_expression, &QQmlExpression::valueChanged, this, &FastExpressionRole::invalidate);
    m_expression->setNotifyOnValueChanged(true);
    m_expression->evaluate();
}

