#pragma once

#include <QVariant>

#include <memory>

class QJsonArray;
class QJsonObject;
class QQmlEngine;
class QAbstractItemModel;

class ListModelWrapper {

public:
    explicit ListModelWrapper(QQmlEngine& engine, const QString& content = "[]");
    explicit ListModelWrapper(QQmlEngine& engine, const QJsonArray& content);

    QAbstractItemModel* model() const;
    operator QAbstractItemModel*() const;

    int count() const;
    int role(const QString& roleName);

    void set(int index, const QJsonObject& dict);
    void setProperty(int index, const QString& property, const QVariant& value);

    QVariant get(int index, const QString& roleName);

    void insert(int index, const QJsonObject& dict);
    void insert(int index, const QJsonArray& data);
    void append(const QJsonArray& data);
    void clear();
    void remove(int index, int count = 1);
    void move(int from, int to, int n = 1);

private:
    void runExpression(const QString& expression);

    std::unique_ptr<QAbstractItemModel> m_model;
};
