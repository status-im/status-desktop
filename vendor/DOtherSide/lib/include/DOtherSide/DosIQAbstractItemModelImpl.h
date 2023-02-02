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
#include <QtCore/QModelIndex>
#include <QtCore/QVariant>
#include <QtCore/QHash>
#include <QtCore/QByteArray>
#include <QtCore/QVector>

// DOtherSide
#include "DOtherSide/DosIQObjectImpl.h"

namespace DOS {

class DosIQAbstractItemModelImpl : public DosIQObjectImpl
{
public:
    /// Destructor
    virtual ~DosIQAbstractItemModelImpl() = default;

    /// @see QAbstractItemModel::setData
    virtual bool defaultSetData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) = 0;

    /// @see QAbstractItemModel::flags
    virtual Qt::ItemFlags defaultFlags(const QModelIndex &index) const = 0;

    /// @see QAbstractItemModel::headerData
    virtual QVariant defaultHeaderData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const = 0;

    /// @see QAbstractItemModel::roleNames
    virtual QHash<int, QByteArray> defaultRoleNames() const = 0;

    /// @see QAbstractItemModel::beginInsertRows
    virtual void publicBeginInsertRows(const QModelIndex &index, int first, int last) = 0;

    /// @see QAbstractItemModel::endInsertRows
    virtual void publicEndInsertRows() = 0;

    /// @see QAbstractItemModel::beginRemoveRows
    virtual void publicBeginRemoveRows(const QModelIndex &index, int first, int last) = 0;

    /// @see QAbstractItemModel::endRemoveRows
    virtual void publicEndRemoveRows() = 0;

    /// @see QAbstractItemModel::beginInsertColumns
    virtual void publicBeginInsertColumns(const QModelIndex &index, int first, int last) = 0;

    /// @see QAbstractItemModel::endInsertColumns
    virtual void publicEndInsertColumns() = 0;

    /// @see QAbstractItemModel::beginRemoveColumns
    virtual void publicBeginRemoveColumns(const QModelIndex &index, int first, int last) = 0;

    /// @see QAbstractItemModel::endRemoveColumns
    virtual void publicEndRemoveColumns() = 0;

    /// @see QAbstractItemModel::beginResetModel
    virtual void publicBeginResetModel() = 0;

    /// @see QAbstractItemModel::endResetModel
    virtual void publicEndResetModel() = 0;

    /// @see QAbstractItemModel::dataChanged
    virtual void publicDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>()) = 0;

    /// @see QAbstractItemModel::createIndex
    virtual QModelIndex publicCreateIndex(int row, int column, void *data = nullptr) const = 0;

    /// @see QAbstractItemModel::hasChildren
    virtual bool defaultHasChildren(const QModelIndex &parent) const = 0;

    /// @see QAbstractItemModel::canFetchMore
    virtual bool defaultCanFetchMore(const QModelIndex &parent) const = 0;

    /// @see QAbstractItemModel::fetchMore
    virtual void defaultFetchMore(const QModelIndex &parent) = 0;

    ///  @see QAbstractItemModel::hasIndex
    virtual bool hasIndex(int row, int column, const QModelIndex &parent = QModelIndex()) const = 0;
};
} // namespace dos
