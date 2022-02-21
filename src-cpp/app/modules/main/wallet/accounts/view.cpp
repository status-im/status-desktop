#include <QDebug>

#include "view.h"

namespace Modules::Main::Wallet::Accounts
{
View::View(QObject* parent)
    : QObject(parent)
{
    m_modelPtr = new Model(this);
}

void View::load()
{
    emit viewLoaded();
}

Model* View::getModel()
{
    return m_modelPtr;
}

void View::setModelItems(QVector<Item>& accounts)
{
    m_modelPtr->setItems(accounts);
    modelChanged();
}
} // namespace Modules::Main::Wallet::Accounts
