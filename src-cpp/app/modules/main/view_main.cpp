#include "view_main.h"
#include "../global/app_sections_config.h"

namespace Modules::Main
{
View::View(QObject* parent)
    : QObject(parent)
{
    m_sectionModelPtr = new Shared::Models::SectionModel(this);
}

void View::load()
{
    // Add Wallet Section to Sections model
    auto walletSectionItem = new Shared::Models::SectionItem(WALLET_SECTION_ID,
                                                             Shared::Models::SectionType::Wallet,
                                                             WALLET_SECTION_NAME,
                                                             "",
                                                             "",
                                                             WALLET_SECTION_ICON,
                                                             "",
                                                             false,
                                                             this);
    addItem(walletSectionItem);
    setActiveSection(WALLET_SECTION_ID);

    emit viewLoaded();
}

void View::addItem(Shared::Models::SectionItem* item)
{
    m_sectionModelPtr->addItem(item);
    emit sectionsModelChanged();
}

Shared::Models::SectionModel* View::getSectionsModel()
{
    return m_sectionModelPtr;
}

Shared::Models::SectionItem* View::getActiveSection()
{
    return m_sectionModelPtr->getActiveItem();
}

void View::setActiveSection(const QString& Id)
{
    if(m_sectionModelPtr->getActiveItem().isNull() || (m_sectionModelPtr->getActiveItem()->getId() != Id))
    {
        m_sectionModelPtr->setActiveSection(Id);
        activeSectionChanged();
    }
}

} // namespace Modules::Main
