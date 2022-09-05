#pragma once

#include <QtQmlIntegration>

namespace Status::Wallet
{

class SavedAddressesController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("C++ only")

public:
    SavedAddressesController(QObject* parent = nullptr);
};

} // namespace Status::Wallet
