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
#include <QtCore/QObject>
#include <functional>
// DOtherSide
#include "DOtherSideTypesCpp.h"
#include "DOtherSide/DosIQObjectImpl.h"

namespace DOS {

/// This class model a QObject
class DosQObject : public QObject, public DosIQObjectImpl
{
public:
    /// Constructor
    DosQObject(void *dObjectPointer, DosIQMetaObjectPtr metaObject, DObjectCallback dObjectCallback);

    /// Emit a signal
    bool emitSignal(QObject *emitter, const QString &name, const std::vector<QVariant> &arguments) override;

    /// Return the metaObject
    const QMetaObject *metaObject() const override;

    /// The qt_metacall
    int qt_metacall(QMetaObject::Call, int, void **) override;

private:
    std::unique_ptr<DosIQObjectImpl> m_impl;
};

} // namespace DOS
