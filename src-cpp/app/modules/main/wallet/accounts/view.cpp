#include <QDebug>

#include "view.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
View::View(QObject* parent)
    : QObject(parent)
{
    m_modelPtr = std::make_shared<Model>();
}

void View::load()
{
    emit viewLoaded();
}

Model* View::getModel()
{
    return m_modelPtr.get();
}

void View::setModelItems(QVector<Item> &accounts) {
    m_modelPtr->setItems(accounts);
    modelChanged();
}
} // namespace Accounts
} // namespace Wallet
} // namespace Main
} // namespace Modules
