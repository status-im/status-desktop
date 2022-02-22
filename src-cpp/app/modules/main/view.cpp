#include "view.h"
#include "../global/app_sections_config.h"

namespace Modules::Main
{
void View::load()
{
    // Add Wallet Section to Sections model
    auto walletSectionItem = new Shared::Models::SectionItem(this,
                                                             WALLET_SECTION_ID,
                                                             Shared::Models::SectionType::Wallet,
                                                             WALLET_SECTION_NAME,
                                                             "",
                                                             "",
                                                             WALLET_SECTION_ICON,
                                                             "",
                                                             false,
                                                             true);
    addItem(walletSectionItem);
    setActiveSection(WALLET_SECTION_ID);

    emit viewLoaded();
}

void View::addItem(Shared::Models::SectionItem* item)
{
    m_sectionModel.addItem(item);
    // emit sectionsModelChanged(); // FIXME: that's wrong, sectionModel* property didn't change
}

Shared::Models::SectionModel* View::getSectionsModel()
{
    return &m_sectionModel;
}

Shared::Models::SectionItem* View::getActiveSection() const
{
    return m_sectionModel.getActiveItem();
}

void View::setActiveSection(const QString& Id)
{
    if(m_sectionModel.getActiveItem().isNull() || (m_sectionModel.getActiveItem()->getId() != Id))
    {
        m_sectionModel.setActiveSection(Id);
        activeSectionChanged();
    }
}

} // namespace Modules::Main
