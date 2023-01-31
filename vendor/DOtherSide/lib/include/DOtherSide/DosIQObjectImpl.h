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
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QVariant>
#include <QtCore/QMetaObject>

namespace DOS {

class DosIQObjectImpl
{
public:
    /// Destructor
    virtual ~DosIQObjectImpl() = default;

    /// Emit the signal with the given name and arguments
    virtual bool emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &argumentsValues) = 0;

    /// Return the metaObject
    virtual const QMetaObject *metaObject() const = 0;

    /// The qt_metacall implementation
    virtual int qt_metacall(QMetaObject::Call, int, void **) = 0;
};

} // namespace dos
