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

#include "DOtherSide/DosQObjectImpl.h"

#include "DOtherSide/DosQMetaObject.h"

#include <QtCore/QMetaObject>
#include <QtCore/QMetaMethod>
#include <QtCore/QDebug>

namespace DOS {

DosQObjectImpl::DosQObjectImpl(ParentMetaCall parentMetaCall,
                               std::shared_ptr<const DosIQMetaObject> metaObject,
                               void *dObjectPointer,
                               DObjectCallback dObjectCallback)
    : m_parentMetaCall(std::move(parentMetaCall))
    , m_metaObject(std::move(metaObject))
    , m_dObjectPointer(dObjectPointer)
    , m_dObjectCallback(dObjectCallback)
{
}

bool DosQObjectImpl::emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &args)
{
    const QMetaMethod method = m_metaObject->signal(name);
    if (!method.isValid())
        return false;

    Q_ASSERT(name.toUtf8() == method.name());

    std::vector<void *> arguments(args.size() + 1, nullptr); // +1 for the result at pos 0
    for (size_t i = 0; i < args.size(); ++i)
        arguments[i + 1] = const_cast<void *>(args[i].constData()); // Extract inner void*
    QMetaObject::activate(emitter, method.methodIndex(), arguments.data());
    return true;
}

const QMetaObject *DosQObjectImpl::metaObject() const
{
    return m_metaObject->metaObject();
}

int DosQObjectImpl::qt_metacall(QMetaObject::Call callType, int index, void **args)
{
    if (m_parentMetaCall(callType, index, args) < 0)
        return -1;

    switch (callType) {
    case QMetaObject::InvokeMetaMethod:
        executeSlot(index, args);
        break;
    case QMetaObject::ReadProperty:
        readProperty(index, args);
        break;
    case QMetaObject::WriteProperty:
        writeProperty(index, args);
        break;
    default:
        return -1;
    }

    return -1;
}

bool DosQObjectImpl::executeSlot(int index, void **args)
{
    const QMetaObject *const mo = this->metaObject();
    const QMetaMethod method = mo->method(index);
    if (!method.isValid()) {
        qDebug() << "C++: executeSlot: invalid method";
        return false;
    }
    return executeSlot(method, args);
}

bool DosQObjectImpl::executeSlot(const QMetaMethod &method, void **args, int argumentsOffset)
{
    Q_ASSERT(method.isValid());

    const bool hasReturnType = method.returnType() != QMetaType::Void;

    std::vector<QVariant> arguments;
    arguments.reserve(method.parameterCount());
    for (int i = 0, j = argumentsOffset; i < method.parameterCount(); ++i, ++j) {
        QVariant argument(method.parameterType(i), args[j]);
        arguments.emplace_back(std::move(argument));
    }

    const QVariant result = executeSlot(method.name(), arguments); // Execute method

    if (hasReturnType && result.isValid()) {
        QMetaType::construct(method.returnType(), args[0], result.constData());
    }

    return true;
}

QVariant DosQObjectImpl::executeSlot(const QString &name, const std::vector<QVariant> &args)
{
    QVariant result;

    if (!m_dObjectCallback || !m_dObjectPointer)
        return result;

    // prepare slot name
    QVariant slotName(name);

    // prepare void* for the QVariants
    std::vector<void *> argumentsAsVoidPointers;
    argumentsAsVoidPointers.reserve(args.size() + 1);
    argumentsAsVoidPointers.emplace_back(&result);
    for (size_t i = 0; i < args.size(); ++i)
        argumentsAsVoidPointers.emplace_back((void *)(&args[i]));

    // send them to the binding handler
    m_dObjectCallback(m_dObjectPointer, &slotName, argumentsAsVoidPointers.size(), &argumentsAsVoidPointers[0]);

    return result;
}

bool DosQObjectImpl::readProperty(int index, void **args)
{
    const QMetaObject *const mo = metaObject();
    const QMetaProperty property = mo->property(index);
    if (!property.isValid() || !property.isReadable())
        return false;
    const QMetaMethod method = m_metaObject->readSlot(property.name());
    if (!method.isValid()) {
        qDebug() << "C++: readProperty: invalid read method for property " << property.name();
        return false;
    }
    return executeSlot(method, args);
}

bool DosQObjectImpl::writeProperty(int index, void **args)
{
    const QMetaObject *const mo = metaObject();
    const QMetaProperty property = mo->property(index);
    if (!property.isValid() || !property.isWritable())
        return false;
    const QMetaMethod method = m_metaObject->writeSlot(property.name());
    if (!method.isValid()) {
        qDebug() << "C++: writeProperty: invalid write method for property " << property.name();
        return false;
    }
    return executeSlot(method, args, 0);
}

}
