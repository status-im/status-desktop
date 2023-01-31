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

#include "DOtherSide/DosQObject.h"
#include "DOtherSide/DosQMetaObject.h"
#include <QtQml/qqml.h>

namespace DOS {

template<int, int>
class DosQObjectWrapper : public QObject, public DosIQObjectImpl
{
public:
    static const QMetaObject staticMetaObject;

    /// Constructor
    DosQObjectWrapper(QObject *parent = nullptr);

    /// Destructor
    ~DosQObjectWrapper() override;

    /// @see DosIQObjectImpl::metaObject
    const QMetaObject *metaObject() const override;

    /// @see DosIQObjectImpl::qt_metacall
    int qt_metacall(QMetaObject::Call, int, void **) override;

    /// @see DosIQObjectImpl::emitSignal
    bool emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &argumentsValues) override;

    static const QmlRegisterType &qmlRegisterType();
    static void setQmlRegisterType(QmlRegisterType data);
    static void setStaticMetaObject(const QMetaObject &metaObject);
    static void setId(int id);

private:
    void *m_dObject;
    DosQObject *m_impl;
    static int m_id;
    static QmlRegisterType m_data;
};

template<int N, int M>
const QMetaObject DosQObjectWrapper<N, M>::staticMetaObject = QObject::staticMetaObject;

template<int N, int M>
QmlRegisterType DosQObjectWrapper<N, M>::m_data;

template<int N, int M>
int DosQObjectWrapper<N, M>::m_id = -1;

template<int N, int M>
DosQObjectWrapper<N, M>::DosQObjectWrapper(QObject *parent)
    : QObject(parent)
    , m_dObject(nullptr)
    , m_impl(nullptr)
{
    void *impl = nullptr;
    m_data.createDObject(m_id, static_cast<QObject *>(this), &m_dObject, &impl);
    m_impl = dynamic_cast<DosQObject *>(static_cast<QObject *>(impl));
    Q_ASSERT(m_dObject);
    Q_ASSERT(m_impl);
}

template<int N, int M>
DosQObjectWrapper<N, M>::~DosQObjectWrapper()
{
    m_data.deleteDObject(m_id, m_dObject);
    m_dObject = nullptr;
    delete dynamic_cast<QObject *>(m_impl);
    m_impl = nullptr;
}

template<int N, int M>
const QMetaObject *DosQObjectWrapper<N, M>::metaObject() const
{
    Q_ASSERT(m_impl);
    return m_impl->metaObject();
}

template<int N, int M>
int DosQObjectWrapper<N, M>::qt_metacall(QMetaObject::Call call, int index, void **args)
{
    Q_ASSERT(m_impl);
    return m_impl->qt_metacall(call, index, args);
}

template<int N, int M>
bool DosQObjectWrapper<N, M>::emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &argumentsValues)
{
    Q_ASSERT(m_impl);
    return m_impl->emitSignal(this, name, argumentsValues);
}

template<int N, int M>
void DosQObjectWrapper<N, M>::setQmlRegisterType(QmlRegisterType data)
{
    m_data = std::move(data);
}

template<int N, int M>
void DosQObjectWrapper<N, M>::setStaticMetaObject(const QMetaObject &metaObject)
{
    *(const_cast<QMetaObject *>(&staticMetaObject)) = metaObject;
}

template<int N, int M>
void DosQObjectWrapper<N, M>::setId(int id)
{
    m_id = id;
}

template<int N, int M>
const QmlRegisterType &DosQObjectWrapper<N, M>::qmlRegisterType()
{
    return m_data;
}

namespace DQOW {

template<int N>
using RegisterTypeQObject = DosQObjectWrapper<N, 0>;

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

template<int N>
using RegisterSingletonTypeQObject = DosQObjectWrapper<N, 1>;

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

}
}
