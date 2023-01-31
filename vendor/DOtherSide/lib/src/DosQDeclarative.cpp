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

#include "DOtherSide/DosQDeclarative.h"
#include "DOtherSide/DosQObjectWrapper.h"
#include "DOtherSide/DosQAbstractItemModelWrapper.h"

namespace DOS {

bool isQAbstractItemModel(const QMetaObject *metaObject)
{
    const QMetaObject *current = metaObject;
    while (current) {
        if (&QAbstractItemModel::staticMetaObject == current)
            return true;
        current = current->superClass();
    }
    return false;
}

int dosQmlRegisterType(QmlRegisterType args)
{
    static int i = 0;
    static int j = 0;
    if (isQAbstractItemModel(args.staticMetaObject->metaObject()))
        return DQAIMW::DosQmlRegisterHelper<35>::Register(j++, std::move(args));
    else
        return DQOW::DosQmlRegisterHelper<35>::Register(i++, std::move(args));
}

int dosQmlRegisterSingletonType(QmlRegisterType args)
{
    static int i = 0;
    static int j = 0;
    if (isQAbstractItemModel(args.staticMetaObject->metaObject()))
        return DQAIMW::DosQmlRegisterSingletonHelper<35>::Register(j++, std::move(args));
    else
        return DQOW::DosQmlRegisterSingletonHelper<35>::Register(i++, std::move(args));
}

}
