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

#include "DOtherSide/DosQObject.h"
#include "DOtherSide/DosQMetaObject.h"
#include "DOtherSide/DosQObjectImpl.h"

namespace {
DOS::DosQObjectImpl::ParentMetaCall createParentMetaCall(QObject *parent)
{
    return [parent](QMetaObject::Call callType, int index, void **args) -> int {
        return parent->QObject::qt_metacall(callType, index, args);
    };
}
}

namespace DOS {

DosQObject::DosQObject(void *dObjectPointer, DosIQMetaObjectPtr metaObject, DObjectCallback dObjectCallback)
    : m_impl(new DosQObjectImpl(::createParentMetaCall(this), std::move(metaObject), dObjectPointer, dObjectCallback))
{}

bool DosQObject::emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &args)
{
    Q_ASSERT(m_impl);
    return m_impl->emitSignal(emitter, name, args);
}

const QMetaObject *DosQObject::metaObject() const
{
    Q_ASSERT(m_impl);
    return m_impl->metaObject();
}

int DosQObject::qt_metacall(QMetaObject::Call call, int index, void **args)
{
    Q_ASSERT(m_impl);
    return m_impl->qt_metacall(call, index, args);
}

} // namespace DOS
