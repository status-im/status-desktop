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
#include <vector>
// Qt
#include <QtCore/QMutex>
#include <QtCore/QString>
#include <QtCore/QVariant>
// DOtherSide
#include "DOtherSide/DosQObject.h"
#include "DOtherSide/DOtherSideTypesCpp.h"

namespace DOS {

/// This class implement the interface IDosQObject
/// and it's injected in DosQObject
class DosQObjectImpl : public DosIQObjectImpl
{
public:
    using ParentMetaCall = std::function<int(QMetaObject::Call, int, void **)>;

    /// Constructor
    DosQObjectImpl(ParentMetaCall parentMetaCall,
                   std::shared_ptr<const DosIQMetaObject> metaObject,
                   void *dObjectPointer,
                   DObjectCallback dObjectCallback);


    /// @see IDosQObject::emitSignal
    bool emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &arguments) override;

    /// @see IDosQObject::metaObject()
    const QMetaObject *metaObject() const override;

    /// @see IDosQObject::qt_metacall
    int qt_metacall(QMetaObject::Call, int, void **) override;

private:
    bool executeSlot(const QMetaMethod &method, void **args, int argumentsOffset = 1);
    bool executeSlot(int index, void **args);
    QVariant executeSlot(const QString &name, const std::vector<QVariant> &args);

    bool readProperty(int index, void **args);
    bool writeProperty(int index, void **args);

    const ParentMetaCall m_parentMetaCall;
    const std::shared_ptr<const DosIQMetaObject> m_metaObject;
    void* const m_dObjectPointer = nullptr;
    const DObjectCallback m_dObjectCallback;
};

} // namespace DOS
