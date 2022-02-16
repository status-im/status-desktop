#include <QDebug>

#include "view.h"

namespace Modules::Main::Wallet
{
View::View(QObject* parent)
    : QObject(parent)
{
}

void View::load()
{
    emit viewLoaded();
}

} // namespace Modules::Main::Wallet
