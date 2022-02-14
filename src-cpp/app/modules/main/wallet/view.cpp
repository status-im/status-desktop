#include <QDebug>

#include "view.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
View::View(QObject* parent)
    : QObject(parent)
{
}

void View::load()
{
    emit viewLoaded();
}

} // namespace Wallet
} // namespace Main
} // namespace Modules
