#include <QDebug>

#include "view_wallet.h"

namespace Modules::Main::Wallet
{
View::View(QObject* parent)
    : QObject(parent)
{ }

void View::load()
{
    emit viewLoaded();
}

} // namespace Modules::Main::Wallet
