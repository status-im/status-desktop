#include "listmodelwrapper.h"

#include <QAbstractItemModel>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QQmlExpression>

ListModelWrapper::ListModelWrapper(QQmlEngine& engine, const QString& content)
{
    QQmlComponent component(&engine);
    auto componentBody = QStringLiteral(R"(
        import QtQml 2.15
        import QtQml.Models 2.15

        ListModel {
            Component.onCompleted: {
                const content = %1

                if (content.length)
                    append(content)
            }
        }
    )").arg(content);

    component.setData(componentBody.toUtf8(), {});

    m_model.reset(qobject_cast<QAbstractItemModel*>(
                      component.create(engine.rootContext())));

    Q_ASSERT_X(m_model, "ListModelWrapper", "creating model failed!");
}

ListModelWrapper::ListModelWrapper(QQmlEngine& engine, const QJsonArray& content)
    : ListModelWrapper(engine, QJsonDocument(content).toJson())
{
}

QAbstractItemModel* ListModelWrapper::model() const
{
    return m_model.get();
}

ListModelWrapper::operator QAbstractItemModel*() const
{
    return model();
}

int ListModelWrapper::count() const
{
    return m_model->rowCount();
}

int ListModelWrapper::role(const QString& roleName)
{
    QHash<int, QByteArray> roleNames = m_model->roleNames();
    QList<int> roles = roleNames.keys(roleName.toUtf8());

    return roles.length() != 1 ? -1 : roles.first();
}

void ListModelWrapper::set(int index, const QJsonObject& dict)
{
    QString jsonDict = QJsonDocument(dict).toJson();
    runExpression(QString("set(%1, %2)").arg(index).arg(jsonDict));
}

void ListModelWrapper::setProperty(int index, const QString& property,
                                   const QVariant& value)
{
    QString valueStr = value.type() == QVariant::String
            ? QString("'%1'").arg(value.toString())
            : value.toString();

    runExpression(QString("setProperty(%1, '%2', %3)").arg(index)
                  .arg(property, valueStr));
}

QVariant ListModelWrapper::get(int index, const QString& roleName)
{
    auto role = this->role(roleName);

    if (role == -1)
        return {};

    return m_model->data(m_model->index(index, 0), role);
}

void ListModelWrapper::insert(int index, const QJsonObject& dict) {
    QString jsonDict = QJsonDocument(dict).toJson();
    runExpression(QString("insert(%1, %2)").arg(index).arg(jsonDict));
}

void ListModelWrapper::insert(int index, const QJsonArray& data) {
    QString jsonData = QJsonDocument(data).toJson();
    runExpression(QString("insert(%1, %2)").arg(index).arg(jsonData));
}

void ListModelWrapper::append(const QJsonArray& data) {
    QString jsonData = QJsonDocument(data).toJson();
    runExpression(QString("append(%1)").arg(jsonData));
}

void ListModelWrapper::clear() {
    runExpression(QString("clear()"));
}

void ListModelWrapper::remove(int index, int count) {
    runExpression(QString("remove(%1, %2)").arg(QString::number(index),
                                                QString::number(count)));
}

void ListModelWrapper::move(int from, int to, int n) {
    runExpression(QString("move(%1, %2, %3)").arg(QString::number(from),
                                                  QString::number(to),
                                                  QString::number(n)));
}

void ListModelWrapper::runExpression(const QString& expression)
{
    QQmlExpression(QQmlEngine::contextForObject(m_model.get()),
                   m_model.get(), expression).evaluate();
}
