/*
    Copyright (C) 2019 Filippo Cucchetto.
    Contact: https://github.com/filcuc/dotherside

    This file is part of the DOtherSide library.

    The DOtherSide library is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the license, or (at your opinion) any later version.

    The DOtherSide library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with the DOtherSide library.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma once

#include "DOtherSide/DosQAbstractItemModel.h"
#include "DOtherSide/DosQMetaObject.h"

namespace DOS {
template <int, int>
class DosQAbstractItemModelWrapper : public QAbstractItemModel, public DosIQObjectImpl
{
public:
    static const QMetaObject staticMetaObject;

    /// Constructor
    DosQAbstractItemModelWrapper(QObject *parent = nullptr);

    /// Destructor
    ~DosQAbstractItemModelWrapper() override;

    /// @see DosIQObjectImpl::metaObject
    const QMetaObject *metaObject() const override;

    /// @see DosIQObjectImpl::qt_metacall
    int qt_metacall(QMetaObject::Call, int, void **) override;

    /// @see DosIQObjectImpl::emitSignal
    bool emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &argumentsValues) override;

    /// Return the qml registration type
    static const QmlRegisterType &qmlRegisterType();

    /// Sets the qml registration type
    static void setQmlRegisterType(QmlRegisterType data);

    /// Sets the static metaobject
    static void setStaticMetaObject(const QMetaObject &metaObject);

    /// Sets the qmlRegisterType id
    static void setId(int id);

    /// @see QAbstractItemModel::rowCount
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /// @see QAbstractItemModel::columnCount
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    /// @see QAbstractItemModel::data
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /// @see QAbstractItemModel::setData
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    /// @see QAbstractItemModel::flags
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    /// @see QAbstractItemModel::headerData
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    /// @see QAbstractItemModel::roleNames
    QHash<int, QByteArray> roleNames() const override;

    /// @see QAbstractItemModel::index
    QModelIndex index(int row, int column, const QModelIndex &parent) const override;

    /// @see QAbstractItemModel::parent
    QModelIndex parent(const QModelIndex &child) const override;

private:
    void *m_dObject;
    QAbstractItemModel *m_impl;
    static int m_id;
    static QmlRegisterType m_data;
};

template<int N, int M>
const QMetaObject DosQAbstractItemModelWrapper<N, M>::staticMetaObject = QAbstractItemModel::staticMetaObject;

template<int N, int M>
QmlRegisterType DosQAbstractItemModelWrapper<N, M>::m_data;

template<int N, int M>
int DosQAbstractItemModelWrapper<N, M>::m_id = -1;

template<int N, int M>
DosQAbstractItemModelWrapper<N, M>::DosQAbstractItemModelWrapper(QObject *parent)
    : QAbstractItemModel(parent)
    , m_dObject(nullptr)
    , m_impl(nullptr)
{
    void *impl = nullptr;
    m_data.createDObject(m_id, static_cast<QObject *>(this), &m_dObject, &impl);
    beginResetModel();
    m_impl = dynamic_cast<QAbstractItemModel *>(static_cast<QObject *>(impl));
    QObject::connect(m_impl, &QAbstractItemModel::rowsAboutToBeInserted, this, &DosQAbstractItemModelWrapper<N, M>::beginInsertRows);
    QObject::connect(m_impl, &QAbstractItemModel::rowsInserted, this, &DosQAbstractItemModelWrapper<N, M>::endInsertRows);
    QObject::connect(m_impl, &QAbstractItemModel::rowsAboutToBeRemoved, this, &DosQAbstractItemModelWrapper<N, M>::beginRemoveRows);
    QObject::connect(m_impl, &QAbstractItemModel::rowsRemoved, this, &DosQAbstractItemModelWrapper<N, M>::endRemoveRows);
    QObject::connect(m_impl, &QAbstractItemModel::rowsAboutToBeMoved, this, &DosQAbstractItemModelWrapper<N, M>::beginMoveRows);
    QObject::connect(m_impl, &QAbstractItemModel::rowsMoved, this, &DosQAbstractItemModelWrapper<N, M>::endMoveRows);
    QObject::connect(m_impl, &QAbstractItemModel::columnsAboutToBeInserted, this, &DosQAbstractItemModelWrapper<N, M>::beginInsertColumns);
    QObject::connect(m_impl, &QAbstractItemModel::columnsInserted, this, &DosQAbstractItemModelWrapper<N, M>::endInsertColumns);
    QObject::connect(m_impl, &QAbstractItemModel::columnsAboutToBeRemoved, this, &DosQAbstractItemModelWrapper<N, M>::beginRemoveColumns);
    QObject::connect(m_impl, &QAbstractItemModel::columnsRemoved, this, &DosQAbstractItemModelWrapper<N, M>::endRemoveColumns);
    QObject::connect(m_impl, &QAbstractItemModel::columnsAboutToBeMoved, this, &DosQAbstractItemModelWrapper<N, M>::beginMoveColumns);
    QObject::connect(m_impl, &QAbstractItemModel::columnsMoved, this, &DosQAbstractItemModelWrapper<N, M>::endMoveColumns);
    QObject::connect(m_impl, &QAbstractItemModel::modelAboutToBeReset, this, &DosQAbstractItemModelWrapper<N, M>::beginResetModel);
    QObject::connect(m_impl, &QAbstractItemModel::modelReset, this, &DosQAbstractItemModelWrapper<N, M>::endResetModel);
    QObject::connect(m_impl, &QAbstractItemModel::dataChanged, this, &DosQAbstractItemModelWrapper<N, M>::dataChanged);
    QObject::connect(m_impl, &QAbstractItemModel::layoutAboutToBeChanged, this, &DosQAbstractItemModelWrapper<N, M>::layoutAboutToBeChanged);
    QObject::connect(m_impl, &QAbstractItemModel::layoutChanged, this, &DosQAbstractItemModelWrapper<N, M>::layoutChanged);
    endResetModel();
    Q_ASSERT(m_dObject);
    Q_ASSERT(m_impl);
}

template<int N, int M>
DosQAbstractItemModelWrapper<N, M>::~DosQAbstractItemModelWrapper()
{
    m_data.deleteDObject(m_id, m_dObject);
    m_dObject = nullptr;
    delete m_impl;
    m_impl = nullptr;
}

template<int N, int M>
const QMetaObject *DosQAbstractItemModelWrapper<N, M>::metaObject() const
{
    Q_ASSERT(m_impl);
    return m_impl->metaObject();
}

template<int N, int M>
int DosQAbstractItemModelWrapper<N, M>::qt_metacall(QMetaObject::Call call, int index, void **args)
{
    Q_ASSERT(m_impl);
    return m_impl->qt_metacall(call, index, args);
}

template<int N, int M>
bool DosQAbstractItemModelWrapper<N, M>::emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &argumentsValues)
{
    Q_ASSERT(m_impl);
    return dynamic_cast<DosIQObjectImpl *>(this)->emitSignal(this, name, argumentsValues);
}

template<int N, int M>
void DosQAbstractItemModelWrapper<N, M>::setQmlRegisterType(QmlRegisterType data)
{
    m_data = std::move(data);
}

template<int N, int M>
void DosQAbstractItemModelWrapper<N, M>::setStaticMetaObject(const QMetaObject &metaObject)
{
    *(const_cast<QMetaObject *>(&staticMetaObject)) = metaObject;
}

template<int N, int M>
void DosQAbstractItemModelWrapper<N, M>::setId(int id)
{
    m_id = id;
}

template<int N, int M>
int DosQAbstractItemModelWrapper<N, M>::rowCount(const QModelIndex &parent) const
{
    Q_ASSERT(m_impl);
    return m_impl->rowCount(parent);
}

template<int N, int M>
int DosQAbstractItemModelWrapper<N, M>::columnCount(const QModelIndex &parent) const
{
    Q_ASSERT(m_impl);
    return m_impl->columnCount(parent);
}

template<int N, int M>
QVariant DosQAbstractItemModelWrapper<N, M>::data(const QModelIndex &index, int role) const
{
    Q_ASSERT(m_impl);
    return m_impl->data(index, role);
}

template<int N, int M>
bool DosQAbstractItemModelWrapper<N, M>::setData(const QModelIndex &index, const QVariant &value, int role)
{
    Q_ASSERT(m_impl);
    return m_impl->setData(index, value, role);
}

template<int N, int M>
Qt::ItemFlags DosQAbstractItemModelWrapper<N, M>::flags(const QModelIndex &index) const
{
    Q_ASSERT(m_impl);
    return m_impl->flags(index);
}

template<int N, int M>
QVariant DosQAbstractItemModelWrapper<N, M>::headerData(int section, Qt::Orientation orientation, int role) const
{
    Q_ASSERT(m_impl);
    return m_impl->headerData(section, orientation, role);
}

template<int N, int M>
QHash<int, QByteArray> DosQAbstractItemModelWrapper<N, M>::roleNames() const
{
    Q_ASSERT(m_impl);
    return m_impl->roleNames();
}

template<int N, int M>
QModelIndex DosQAbstractItemModelWrapper<N, M>::index(int row, int column, const QModelIndex &parent) const
{
    Q_ASSERT(m_impl);
    return m_impl->index(row, column, parent);
}

template<int N, int M>
QModelIndex DosQAbstractItemModelWrapper<N, M>::parent(const QModelIndex &child) const
{
    Q_ASSERT(m_impl);
    return m_impl->parent(child);
}

template<int N, int M>
const QmlRegisterType &DosQAbstractItemModelWrapper<N, M>::qmlRegisterType()
{
    return m_data;
}

namespace DQAIMW {

template<int N>
using RegisterTypeQObject = DosQAbstractItemModelWrapper<N, 0>;

template<int N>
int dosQmlRegisterType(QmlRegisterType args)
{
    RegisterTypeQObject<N>::setQmlRegisterType(std::move(args));
    const QmlRegisterType &type = RegisterTypeQObject<N>::qmlRegisterType();
    RegisterTypeQObject<N>::setStaticMetaObject(*(type.staticMetaObject->metaObject()));
    int result = qmlRegisterType<RegisterTypeQObject<N>>(type.uri.c_str(), type.major, type.minor, type.qml.c_str());
    RegisterTypeQObject<N>::setId(result);
    return result;
}

template<int N>
struct DosQmlRegisterHelper {
    static int Register(int i, QmlRegisterType args)
    {
        if (i > N)
            return -1;
        else if (i == N)
            return dosQmlRegisterType<N>(std::move(args));
        else
            return DosQmlRegisterHelper < N - 1 >::Register(i, std::move(args));
    }
};

template<>
struct DosQmlRegisterHelper<0> {
    static int Register(int i, QmlRegisterType args)
    {
        return i == 0 ? dosQmlRegisterType<0>(std::move(args)) : -1;
    }
};

int dosQmlRegisterType(QmlRegisterType args)
{
    static int i = 0;
    return DosQmlRegisterHelper<35>::Register(i++, std::move(args));
}

template<int N>
using RegisterSingletonTypeQObject = DosQAbstractItemModelWrapper<N, 1>;

template<int N>
QObject *singletontype_provider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    return new RegisterSingletonTypeQObject<N>();
}

template<int N>
int dosQmlRegisterSingletonType(QmlRegisterType args)
{
    using Func = QObject * (*)(QQmlEngine *, QJSEngine *);
    Func f = singletontype_provider<N>;

    RegisterSingletonTypeQObject<N>::setQmlRegisterType(std::move(args));
    const QmlRegisterType &type = RegisterSingletonTypeQObject<N>::qmlRegisterType();
    RegisterSingletonTypeQObject<N>::setStaticMetaObject(*(type.staticMetaObject->metaObject()));
    int result = qmlRegisterSingletonType<RegisterSingletonTypeQObject<N>>(type.uri.c_str(), type.major, type.minor, type.qml.c_str(), f);
    RegisterSingletonTypeQObject<N>::setId(result);
    return result;
}

template<int N>
struct DosQmlRegisterSingletonHelper {
    static int Register(int i, QmlRegisterType args)
    {
        if (i > N)
            return -1;
        else if (i == N)
            return dosQmlRegisterSingletonType<N>(std::move(args));
        else
            return DosQmlRegisterSingletonHelper < N - 1 >::Register(i, std::move(args));
    }
};

template<>
struct DosQmlRegisterSingletonHelper<0> {
    static int Register(int i, QmlRegisterType args)
    {
        return i == 0 ? dosQmlRegisterSingletonType<0>(std::move(args)) : -1;
    }
};

int dosQmlRegisterSingletonType(QmlRegisterType args)
{
    static int i = 0;
    return DosQmlRegisterSingletonHelper<35>::Register(i++, std::move(args));
}

}
}
