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

#include "DOtherSide/DOtherSideTypesCpp.h"

namespace DOS {

SignalDefinitions toVector(const ::SignalDefinitions &cType)
{
    return toVector<SignalDefinition>(cType.definitions, cType.count);
}

SlotDefinitions toVector(const ::SlotDefinitions &cType)
{
    return toVector<SlotDefinition>(cType.definitions, cType.count);
}

PropertyDefinitions toVector(const ::PropertyDefinitions &cType)
{
    return toVector<PropertyDefinition>(cType.definitions, cType.count);
}

} // namespace DOS
