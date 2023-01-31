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

#include "DOtherSide/DosQAbstractItemModel.h"
#include "DOtherSide/DosQObjectImpl.h"

namespace {

template<class T>
DOS::DosQObjectImpl::ParentMetaCall createParentMetaCall(DOS::DosQAbstractGenericModel<T> *parent)
{
    return [parent](QMetaObject::Call callType, int index, void **args)->int {
        return parent->T::qt_metacall(callType, index, args);
    };
}

}

namespace DOS {

template<class T>
DosQAbstractGenericModel<T>::DosQAbstractGenericModel(void *modelObject,
                                                      DosIQMetaObjectPtr metaObject,
                                                      DObjectCallback dObjectCallback,
                                                      DosQAbstractItemModelCallbacks callbacks)
    : m_impl(new DosQObjectImpl(::createParentMetaCall(this), std::move(metaObject), modelObject, dObjectCallback))
    , m_modelObject(modelObject)
    , m_callbacks(callbacks)
{}

template<class T>
bool DosQAbstractGenericModel<T>::emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &argumentsValues)
{
    Q_ASSERT(m_impl);
    return m_impl->emitSignal(emitter, name, argumentsValues);
}

template<class T>
const QMetaObject *DosQAbstractGenericModel<T>::metaObject() const
{
    Q_ASSERT(m_impl);
    return m_impl->metaObject();
}

template<class T>
int DosQAbstractGenericModel<T>::qt_metacall(QMetaObject::Call call, int index, void **args)
{
    Q_ASSERT(m_impl);
    return m_impl->qt_metacall(call, index, args);
}

template<class T>
int DosQAbstractGenericModel<T>::rowCount(const QModelIndex &parent) const
{
    int result;
    m_callbacks.rowCount(m_modelObject, &parent, &result);
    return result;
}

template<class T>
int DosQAbstractGenericModel<T>::columnCount(const QModelIndex &parent) const
{
    int result;
    m_callbacks.columnCount(m_modelObject, &parent, &result);
    return result;
}

template<class T>
QVariant DosQAbstractGenericModel<T>::data(const QModelIndex &index, int role) const
{
    QVariant result;
    m_callbacks.data(m_modelObject, &index, role, &result);
    return result;
}

template<class T>
bool DosQAbstractGenericModel<T>::setData(const QModelIndex &index, const QVariant &value, int role)
{
    bool result = false;
    m_callbacks.setData(m_modelObject, &index, &value, role, &result);
    return result;
}

template<class T>
Qt::ItemFlags DosQAbstractGenericModel<T>::flags(const QModelIndex &index) const
{
    int result;
    m_callbacks.flags(m_modelObject, &index, &result);
    return Qt::ItemFlags(result);
}

template<class T>
QVariant DosQAbstractGenericModel<T>::headerData(int section, Qt::Orientation orientation, int role) const
{
    QVariant result;
    m_callbacks.headerData(m_modelObject, section, orientation, role, &result);
    return result;
}

template<class T>
QModelIndex DosQAbstractGenericModel<T>::index(int row, int column, const QModelIndex &parent) const
{
    QModelIndex result;
    m_callbacks.index(m_modelObject, row, column, &parent, &result);
    return result;
}

template<class T>
QModelIndex DosQAbstractGenericModel<T>::parent(const QModelIndex &child) const
{
    QModelIndex result;
    m_callbacks.parent(m_modelObject, &child, &result);
    return result;
}

template<class T>
void *DosQAbstractGenericModel<T>::modelObject()
{
    return m_modelObject;
}

template<class T>
QHash<int, QByteArray> DosQAbstractGenericModel<T>::roleNames() const
{
    QHash<int, QByteArray> result;
    m_callbacks.roleNames(m_modelObject, &result);
    return result;
}

template<class T>
void DosQAbstractGenericModel<T>::publicBeginInsertColumns(const QModelIndex &index, int first, int last)
{
    T::beginInsertColumns(index, first, last);
}

template<class T>
void DosQAbstractGenericModel<T>::publicEndInsertColumns()
{
    T::endInsertColumns();
}

template<class T>
void DosQAbstractGenericModel<T>::publicBeginRemoveColumns(const QModelIndex &index, int first, int last)
{
    T::beginRemoveColumns(index, first, last);
}

template<class T>
void DosQAbstractGenericModel<T>::publicEndRemoveColumns()
{
    T::endRemoveColumns();
}
template<class T>
void DosQAbstractGenericModel<T>::publicBeginInsertRows(const QModelIndex &index, int first, int last)
{
    T::beginInsertRows(index, first, last);
}

template<class T>
void DosQAbstractGenericModel<T>::publicEndInsertRows()
{
    T::endInsertRows();
}

template<class T>
void DosQAbstractGenericModel<T>::publicBeginRemoveRows(const QModelIndex &index, int first, int last)
{
    T::beginRemoveRows(index, first, last);
}

template<class T>
void DosQAbstractGenericModel<T>::publicEndRemoveRows()
{
    T::endRemoveRows();
}

template<class T>
void DosQAbstractGenericModel<T>::publicBeginResetModel()
{
    T::beginResetModel();
}

template<class T>
void DosQAbstractGenericModel<T>::publicEndResetModel()
{
    T::endResetModel();
}

template<class T>
void DosQAbstractGenericModel<T>::publicDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    emit T::dataChanged(topLeft, bottomRight, roles);
}

template<class T>
QModelIndex DosQAbstractGenericModel<T>::publicCreateIndex(int row, int column, void *data) const
{
    return T::createIndex(row, column, data);
}

template<class T>
Qt::ItemFlags DosQAbstractGenericModel<T>::defaultFlags(const QModelIndex &index) const
{
    return T::flags(index);
}

template<class T>
QVariant DosQAbstractGenericModel<T>::defaultHeaderData(int section, Qt::Orientation orientation, int role) const
{
    return T::headerData(section, orientation, role);
}

template<class T>
QHash<int, QByteArray> DosQAbstractGenericModel<T>::defaultRoleNames() const
{
    return T::roleNames();
}

template<class T>
bool DosQAbstractGenericModel<T>::defaultSetData(const QModelIndex &index, const QVariant &value, int role)
{
    return T::setData(index, value, role);
}

template<class T>
bool DosQAbstractGenericModel<T>::hasChildren(const QModelIndex &parent) const
{
    bool result = false;
    m_callbacks.hasChildren(m_modelObject, &parent, &result);
    return result;
}

template<class T>
bool DosQAbstractGenericModel<T>::hasIndex(int row, int column, const QModelIndex &parent) const
{
    return T::hasIndex(row, column, parent);
}

template<class T>
bool DosQAbstractGenericModel<T>::canFetchMore(const QModelIndex &parent) const
{
    bool result = false;
    m_callbacks.canFetchMore(m_modelObject, &parent, &result);
    return result;
}

template<class T>
bool DosQAbstractGenericModel<T>::defaultCanFetchMore(const QModelIndex &parent) const
{
    return this->T::canFetchMore(parent);
}

template<class T>
void DosQAbstractGenericModel<T>::fetchMore(const QModelIndex &parent)
{
    m_callbacks.fetchMore(m_modelObject, &parent);
}

template<class T>
void DosQAbstractGenericModel<T>::defaultFetchMore(const QModelIndex &parent)
{
    this->T::fetchMore(parent);
}

QModelIndex DosQAbstractListModel::defaultIndex(int row, int column, const QModelIndex &parent) const
{
    return QAbstractListModel::index(row, column, parent);
}

int DosQAbstractListModel::defaultColumnCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : 1;
}

bool DosQAbstractListModel::defaultHasChildren(const QModelIndex &parent) const
{
    return parent.isValid() ? false : (rowCount() > 0);
}

QModelIndex DosQAbstractListModel::defaultParent(const QModelIndex & /*child*/) const
{
    return QModelIndex();
}

QModelIndex DosQAbstractTableModel::defaultIndex(int row, int column, const QModelIndex &parent) const
{
    return hasIndex(row, column, parent) ? createIndex(row, column) : QModelIndex();
}

bool DosQAbstractTableModel::defaultHasChildren(const QModelIndex &parent) const
{
    if (parent.model() == this || !parent.isValid())
        return rowCount(parent) > 0 && columnCount(parent) > 0;
    return false;
}

QModelIndex DosQAbstractTableModel::defaultParent(const QModelIndex & /*child*/) const
{
    return QModelIndex();
}

bool DosQAbstractItemModel::defaultHasChildren(const QModelIndex &parent) const
{
    return QAbstractItemModel::hasChildren(parent);
}

} // namespace DOS

// Force instantiation
template class DOS::DosQAbstractGenericModel<QAbstractItemModel>;
template class DOS::DosQAbstractGenericModel<QAbstractListModel>;
template class DOS::DosQAbstractGenericModel<QAbstractTableModel>;
