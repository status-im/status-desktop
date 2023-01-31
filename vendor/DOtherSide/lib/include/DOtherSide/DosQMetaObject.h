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

// std
#include <memory>
#include <unordered_map>
#include <tuple>
// Qt
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QHash>
#include <QtCore/QMetaMethod>
#include <QtCore/QAbstractItemModel>
#include <QtCore/QAbstractListModel>
#include <QtCore/QAbstractTableModel>
// DOtherSide
#include "DOtherSide/DOtherSideTypesCpp.h"

namespace DOS {

/// This the QMetaObject wrapper
class DosIQMetaObject
{
public:
    virtual ~DosIQMetaObject() = default;
    virtual const QMetaObject *metaObject() const = 0;
    virtual QMetaMethod signal(const QString &signalName) const = 0;
    virtual QMetaMethod readSlot(const char *propertyName) const = 0;
    virtual QMetaMethod writeSlot(const char *propertyName) const = 0;
    virtual const DosIQMetaObject *superClassDosMetaObject() const = 0;
};

/// Base class for any DosIQMetaObject
class BaseDosQMetaObject : public DosIQMetaObject
{
public:
    BaseDosQMetaObject(QMetaObject *metaObject);

    const QMetaObject *metaObject() const override;
    QMetaMethod signal(const QString &signalName) const override;
    QMetaMethod readSlot(const char *propertyName) const override;
    QMetaMethod writeSlot(const char *propertyName) const override;
    const DosIQMetaObject *superClassDosMetaObject() const override;

protected:
    SafeQMetaObjectPtr m_metaObject;
};

/// This is the DosQMetaObject for a QObject
class DosQObjectMetaObject : public BaseDosQMetaObject
{
public:
    DosQObjectMetaObject();
};

/// This is the DosQMetaObject for a QAbstractItemModel
template<class T>
class DosQAbstractGenericModelMetaObject : public BaseDosQMetaObject
{
public:
    DosQAbstractGenericModelMetaObject();
};

using DosQAbstractItemModelMetaObject = DosQAbstractGenericModelMetaObject<QAbstractItemModel>;
using DosQAbstractListModelMetaObject = DosQAbstractGenericModelMetaObject<QAbstractListModel>;
using DosQAbstractTableModelMetaObject = DosQAbstractGenericModelMetaObject<QAbstractTableModel>;

/// This the generic version used by subclasses of QObject or QAbstractItemModels
class DosQMetaObject : public BaseDosQMetaObject
{
public:
    DosQMetaObject(DosIQMetaObjectPtr superClassDosMetaObject,
                   const QString &className,
                   const SignalDefinitions &signalDefinitions,
                   const SlotDefinitions &slotDefinitions,
                   const PropertyDefinitions &propertyDefinitions);

    QMetaMethod signal(const QString &signalName) const override;
    QMetaMethod readSlot(const char *propertyName) const override;
    QMetaMethod writeSlot(const char *propertyName) const override;
    const DosIQMetaObject *superClassDosMetaObject() const override;

private:
    QMetaObject *createMetaObject(const QString &className,
                                  const SignalDefinitions &signalDefinitions,
                                  const SlotDefinitions &slotDefinitions,
                                  const PropertyDefinitions &propertyDefinitions);

    const DosIQMetaObjectPtr m_superClassDosMetaObject;
    QHash<QString, int> m_signalIndexByName;
    QHash<QString, QPair<int, int>> m_propertySlots;
};

/// This class simply holds a ptr to a IDosQMetaObject
/// It's created and passed to the binded language
class DosIQMetaObjectHolder
{
public:
    DosIQMetaObjectHolder(DosIQMetaObjectPtr ptr)
        : m_data(std::move(ptr))
    {}

    const DosIQMetaObjectPtr &data() const
    {
        return m_data;
    }

private:
    const DosIQMetaObjectPtr m_data;
};

} // namespace DOS
