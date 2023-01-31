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
#include <algorithm>
#include <functional>
#include <type_traits>
// Qt
#include <QtCore/QtGlobal>

namespace DOS {

template<class Lambda>
struct DeferHelper {
    DeferHelper(Lambda lambda)
        : m_lambda(std::move(lambda))
    {}

    ~DeferHelper()
    {
        try {
            m_lambda();
        } catch (...) {}
    }

    Lambda m_lambda;
};

template<typename Lambda>
DeferHelper<Lambda> defer(Lambda l)
{
    return DeferHelper<Lambda>(std::move(l));
}



template <typename T>
struct wrapped_array {
    wrapped_array(T *first, T *last) : begin_ {first}, end_ {last} {}
    wrapped_array(T *first, std::ptrdiff_t size)
        : wrapped_array {first, first + size} {}

    T  *begin() const Q_DECL_NOEXCEPT
    {
        return begin_;
    }
    T  *end() const Q_DECL_NOEXCEPT
    {
        return end_;
    }

    T *begin_;
    T *end_;
};

template <typename T>
wrapped_array<T> wrap_array(T *first, std::ptrdiff_t size) Q_DECL_NOEXCEPT
{ return {first, size}; }

template <typename T, typename G>
std::vector<T> toVector(G *first, std::ptrdiff_t size) Q_DECL_NOEXCEPT {
    const wrapped_array<G> array = wrap_array(first, size);
    std::vector<T> result;
    for (auto it = array.begin(); it != array.end(); ++it)
        result.emplace_back(T(*it));
    return result;
}

template <typename T, typename K, typename R = typename std::result_of<K(T)>::type>
std::vector<R> toVector(T *first, std::ptrdiff_t size, K f) Q_DECL_NOEXCEPT {
    wrapped_array<T> array = wrap_array<T>(first, size);
    std::vector<R> result;
    for (auto it = array.begin(); it != array.end(); ++it)
        result.emplace_back(R(f(*it)));
    return result;
}

}
