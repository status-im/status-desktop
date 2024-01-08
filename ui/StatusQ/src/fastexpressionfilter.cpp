#include "StatusQ/fastexpressionfilter.h"

#include <qqmlsortfilterproxymodel.h>

using namespace qqsfpm;

/*!
    \qmltype FastExpressionFilter
    \inherits Filter
    \inqmlmodule StatusQ
    \brief A custom filter similar to (and based on) SFPM's ExpressionFilter but
    optimized to access only explicitly indicated roles.

    A FastExpressionFilter, similarly as \l ExpressionFilter, is a \l Filter
    allowing to implement a filtering based on a javascript expression.
    However in FastExpressionFilter's expression context there are available
    only roles explicitly listed in \l expectedRoles property:

    \code
    SortFilterProxyModel {
       sourceModel: mySourceModel
       filters: FastExpressionFilter {
           expression: model.a < 4 && model.b < 10
           expectedRoles: ["a", "b"]
      }
    }
    \endcode

    By accessing only needed roles, the performance is significantly better in
    comparison to ExpressionFilter.
*/

/*!
    \qmlproperty expression FastExpressionFilter::expression

    See ExpressionFilter::expression for details. Unlike the original
    ExpressionFilter only roles explicitly declared via expectedRoles are accessible.
*/
const QQmlScriptString& FastExpressionFilter::expression() const
{
    return m_scriptString;
}

void FastExpressionFilter::setExpression(const QQmlScriptString& scriptString)
{
    if (m_scriptString == scriptString)
        return;

    m_scriptString = scriptString;
    updateExpression();

    emit expressionChanged();
    invalidate();
}

void FastExpressionFilter::proxyModelCompleted(const QQmlSortFilterProxyModel& proxyModel)
{
    updateContext(proxyModel);
}

/*!
    \qmlproperty list<string> FastExpressionFilter::expectedRoles

    List of role names intended to be available in the expression's context.
*/
void FastExpressionFilter::setExpectedRoles(const QStringList& expectedRoles)
{
    if (m_expectedRoles == expectedRoles)
        return;

    m_expectedRoles = expectedRoles;
    emit expectedRolesChanged();

    invalidate();
}

const QStringList &FastExpressionFilter::expectedRoles() const
{
    return m_expectedRoles;
}

bool FastExpressionFilter::filterRow(const QModelIndex& sourceIndex,
                                 const QQmlSortFilterProxyModel& proxyModel) const
{
    if (m_scriptString.isEmpty())
        return true;

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

        addToContext(it.value(), proxyModel.sourceData(sourceIndex, it.key()));
    }

    addToContext(QStringLiteral("index"), sourceIndex.row());
    context.setContextProperty(QStringLiteral("model"), modelMap);

    QQmlExpression expression(m_scriptString, &context);
    QVariant result = expression.evaluate();

    if (expression.hasError()) {
        qWarning() << expression.error();
        return true;
    }

    if (result.canConvert<bool>()) {
        return result.toBool();
    } else {
        qWarning("%s:%i:%i : Can't convert result to bool",
                 expression.sourceFile().toUtf8().data(),
                 expression.lineNumber(),
                 expression.columnNumber());
        return true;
    }
}

void FastExpressionFilter::updateContext(const QQmlSortFilterProxyModel& proxyModel)
{
    m_context = std::make_unique<QQmlContext>(qmlContext(this));

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

void FastExpressionFilter::updateExpression()
{
    if (!m_context)
        return;

    m_expression = std::make_unique<QQmlExpression>(m_scriptString,
                                                    m_context.get());
    connect(m_expression.get(), &QQmlExpression::valueChanged, this,
            &FastExpressionFilter::invalidate);
    m_expression->setNotifyOnValueChanged(true);
    m_expression->evaluate();
}
