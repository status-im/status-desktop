#pragma once

#include <QObject>
#include <memory>

#include "../shared/section_model.h"

namespace Modules::Main
{
class View : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Shared::Models::SectionModel* sectionsModel READ getSectionsModel NOTIFY sectionsModelChanged)
    Q_PROPERTY(Shared::Models::SectionItem* activeSection READ getActiveSection NOTIFY activeSectionChanged)

public:
    using QObject::QObject;

    void load();

    void addItem(Shared::Models::SectionItem* item);

    void setActiveSection(const QString& Id);

signals:
    void viewLoaded();
    void sectionsModelChanged();
    void activeSectionChanged();

private:
    Shared::Models::SectionModel* getSectionsModel();
    Shared::Models::SectionItem* getActiveSection() const;

    Shared::Models::SectionModel m_sectionModel;
};
} // namespace Modules::Main
