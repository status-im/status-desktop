#include "StatusQ/fastexpressionsorter.h"

#include <qqmlsortfilterproxymodel.h>

using namespace qqsfpm;

/*!
    \qmltype FastExpressionSorter
    \inherits Sorter
    \inqmlmodule StatusQ
    \brief A custom sorter similar to (and based on) SFPM's ExpressionSorter but
    optimized to access only explicitly indicated roles.

    A FastExpressionSorter, similarly as \l ExpressionSorter, is a \l Sorter
    allowing to implement sorting based on a javascript expression.
    However in FastExpressionSorter's expression context there are available
    only roles explicitly listed in \l expectedRoles property:

    \code
    SortFilterProxyModel {
       sourceModel: mySourceModel
       sorter: FastExpressionSorter {
           expression: modelLeft.a < modelRight.a
           expectedRoles: ["a"]
      }
    }
    \endcode

    By accessing only needed roles, the performance is significantly better in
    comparison to ExpressionSorter.
*/

/*!
    \qmlproperty expression FastExpressionSorter::expression

    See ExpressionSorter::expression for details. Unlike the original
    ExpressionSorter only roles explicitly declared via expectedRoles are accessible.
*/
const QQmlScriptString& FastExpressionSorter::expression() const
{
    return m_scriptString;
}

void FastExpressionSorter::setExpression(const QQmlScriptString& scriptString)
{
    if (m_scriptString == scriptString)
        return;

    m_scriptString = scriptString;
    updateExpression();

    emit expressionChanged();
    invalidate();
}

void FastExpressionSorter::proxyModelCompleted(const QQmlSortFilterProxyModel& proxyModel)
{
    updateContext(proxyModel);
}

/*!
    \qmlproperty list<string> FastExpressionSorter::expectedRoles

    List of role names intended to be available in the expression's context.
*/
void FastExpressionSorter::setExpectedRoles(const QStringList& expectedRoles)
{
    if (m_expectedRoles == expectedRoles)
        return;

    m_expectedRoles = expectedRoles;
    emit expectedRolesChanged();

    invalidate();
}

const QStringList &FastExpressionSorter::expectedRoles() const
{
    return m_expectedRoles;
}

bool evaluateBoolExpression(QQmlExpression& expression)
{
    QVariant variantResult = expression.evaluate();
    if (expression.hasError()) {
        qWarning() << expression.error();
        return false;
    }

    if (variantResult.canConvert<bool>())
        return variantResult.toBool();

    qWarning("%s:%i:%i : Can't convert result to bool",
             expression.sourceFile().toUtf8().data(),
             expression.lineNumber(),
             expression.columnNumber());
    return false;
}

int FastExpressionSorter::compare(const QModelIndex& sourceLeft,
                                  const QModelIndex& sourceRight,
                                  const QQmlSortFilterProxyModel& proxyModel) const
{
    if (m_scriptString.isEmpty())
        return 0;

    QVariantMap modelLeftMap, modelRightMap;
    QHash<int, QByteArray> roles = proxyModel.roleNames();

    QQmlContext context(qmlContext(this));

    for (auto it = roles.cbegin(); it != roles.cend(); ++it) {
        auto role = it.key();
        auto name = it.value();

        if (!m_expectedRoles.contains(name))
            continue;

        modelLeftMap.insert(name, proxyModel.sourceData(sourceLeft, role));
        modelRightMap.insert(name, proxyModel.sourceData(sourceRight, role));
    }
    modelLeftMap.insert(QStringLiteral("index"), sourceLeft.row());
    modelRightMap.insert(QStringLiteral("index"), sourceRight.row());

    QQmlExpression expression(m_scriptString, &context);

    context.setContextProperty(QStringLiteral("modelLeft"), modelLeftMap);
    context.setContextProperty(QStringLiteral("modelRight"), modelRightMap);

    if (evaluateBoolExpression(expression))
        return -1;

    context.setContextProperty(QStringLiteral("modelLeft"), modelRightMap);
    context.setContextProperty(QStringLiteral("modelRight"), modelLeftMap);

    if (evaluateBoolExpression(expression))
        return 1;

    return 0;
}

void FastExpressionSorter::updateContext(const QQmlSortFilterProxyModel& proxyModel)
{
    m_context = std::make_unique<QQmlContext>(qmlContext(this));

    QVariantMap modelLeftMap, modelRightMap;

    const auto roleNames = proxyModel.roleNames();
    for (const QByteArray& name : roleNames) {
        if (!m_expectedRoles.contains(name))
            continue;

        modelLeftMap.insert(name, {});
        modelRightMap.insert(name, {});
    }
    modelLeftMap.insert(QStringLiteral("index"), -1);
    modelRightMap.insert(QStringLiteral("index"), -1);

    m_context->setContextProperty(QStringLiteral("modelLeft"), modelLeftMap);
    m_context->setContextProperty(QStringLiteral("modelRight"), modelRightMap);

    updateExpression();
}

void FastExpressionSorter::updateExpression()
{
    if (!m_context)
        return;

    m_expression = std::make_unique<QQmlExpression>(m_scriptString,
                                                    m_context.get());

    connect(m_expression.get(), &QQmlExpression::valueChanged, this,
            &FastExpressionSorter::invalidate);
    m_expression->setNotifyOnValueChanged(true);
    m_expression->evaluate();
}
