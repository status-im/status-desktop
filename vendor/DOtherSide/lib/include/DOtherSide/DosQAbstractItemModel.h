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

// Qt
#include <QtCore/QAbstractItemModel>
#include <QtCore/QAbstractListModel>
#include <QtCore/QAbstractTableModel>

// DOtherSide
#include "DOtherSide/DOtherSideTypes.h"
#include "DOtherSide/DosQMetaObject.h"
#include "DOtherSide/DosIQAbstractItemModelImpl.h"

namespace DOS {

template<class T>
class DosQAbstractGenericModel : public T, public DosIQAbstractItemModelImpl
{
public:
    /// Constructor
    DosQAbstractGenericModel(void *modelObject,
                             DosIQMetaObjectPtr metaObject,
                             DObjectCallback dObjectCallback,
                             DosQAbstractItemModelCallbacks callbacks);

    /// @see IDynamicQObject::emitSignal
    bool emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &argumentsValues) override;

    /// @see QAbstractItemModel::metaObject()
    const QMetaObject *metaObject() const override;

    /// @see QAbstractItemModel::qt_metacall
    int qt_metacall(QMetaObject::Call, int, void **) override;

    /// Return the model's row count
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /// Return the model's column count
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    /// Return the QVariant at the given index
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    /// Sets the QVariant value at the given index and role
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    /// Return the item flags for the given index
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    /// Return the data for the given role and section in the header with the specified orientation
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    /// Return the index associated at the given row and column
    QModelIndex index(int row, int column, const QModelIndex &parent) const override;

    /// Return the parent for the given child index
    QModelIndex parent(const QModelIndex &child) const override;

    /// Return the dModelPointer
    void *modelObject();

    /// Return the roleNames
    QHash<int, QByteArray> roleNames() const override;

    /// Expose beginInsertRows
    void publicBeginInsertRows(const QModelIndex &index, int first, int last) override;

    /// Expose endInsertRows
    void publicEndInsertRows() override;

    /// Expose beginRemoveRows
    void publicBeginRemoveRows(const QModelIndex &index, int first, int last) override;

    /// Expose endInsertRows
    void publicEndRemoveRows() override;

    /// Expose beginInsertColumns
    void publicBeginInsertColumns(const QModelIndex &index, int first, int last) override;

    /// Expose endInsertColumns
    void publicEndInsertColumns() override;

    /// Expose beginRemoveColumns
    void publicBeginRemoveColumns(const QModelIndex &index, int first, int last) override;

    /// Expose endInsertColumns
    void publicEndRemoveColumns() override;

    /// Expose beginResetModel
    void publicBeginResetModel() override;

    /// Expose endResetModel
    void publicEndResetModel() override;

    /// Expose dataChanged
    void publicDataChanged(const QModelIndex &topLeft,
                           const QModelIndex &bottomRight,
                           const QVector<int> &roles = QVector<int>()) override;

    /// Expose createIndex
    QModelIndex publicCreateIndex(int row, int column, void *data = nullptr) const override;

    /// Expose the not overriden flags
    Qt::ItemFlags defaultFlags(const QModelIndex &index) const override;

    /// Expose the not overriden header data
    QVariant defaultHeaderData(int section, Qt::Orientation orientation, int role) const override;

    /// Expose the not overriden roleNames
    QHash<int, QByteArray> defaultRoleNames() const override;

    /// Expose the not overriden setData
    bool defaultSetData(const QModelIndex &index, const QVariant &value, int role) override;

    /// Expose the hasChildren
    bool hasChildren(const QModelIndex &parent = QModelIndex()) const override;

    /// Expose hasIndex
    bool hasIndex(int row, int column, const QModelIndex &parent) const override;

    /// Expose the canFetchMore
    bool canFetchMore(const QModelIndex &parent) const override;

    /// Expose the not override canFetchMore
    bool defaultCanFetchMore(const QModelIndex &parent) const override;

    /// Expose the fetchMore
    void fetchMore(const QModelIndex &parent) override;

    /// Expose the not overriden fetchMore
    void defaultFetchMore(const QModelIndex &parent) override;

private:
    std::unique_ptr<DosIQObjectImpl> m_impl;
    void *m_modelObject;
    DosQAbstractItemModelCallbacks m_callbacks;
};

class DosQAbstractItemModel : public DosQAbstractGenericModel<QAbstractItemModel>
{
public:
    using DosQAbstractGenericModel::DosQAbstractGenericModel;

    bool defaultHasChildren(const QModelIndex &parent) const override;
};

class DosQAbstractTableModel : public DosQAbstractGenericModel<QAbstractTableModel>
{
public:
    using DosQAbstractGenericModel::DosQAbstractGenericModel;

    QModelIndex defaultParent(const QModelIndex &child) const;
    QModelIndex defaultIndex(int row, int column, const QModelIndex &parent = QModelIndex()) const;
    bool defaultHasChildren(const QModelIndex &parent) const override;
};

class DosQAbstractListModel : public DosQAbstractGenericModel<QAbstractListModel>
{
public:
    using DosQAbstractGenericModel::DosQAbstractGenericModel;

    QModelIndex defaultParent(const QModelIndex &child) const;
    QModelIndex defaultIndex(int row, int column, const QModelIndex &parent = QModelIndex()) const;
    int defaultColumnCount(const QModelIndex &parent) const;
    bool defaultHasChildren(const QModelIndex &parent) const override;
};

} // namespace DOS
