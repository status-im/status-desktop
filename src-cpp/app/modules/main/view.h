#ifndef VIEW_H
#define VIEW_H

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
    explicit View(QObject* parent = nullptr);
    ~View() = default;
    void load();

    void addItem(Shared::Models::SectionItem* item);

    Shared::Models::SectionModel* getSectionsModel() const;
    Shared::Models::SectionItem* getActiveSection() const;
    void setActiveSection(const QString& Id);

signals:
    void viewLoaded();
    void sectionsModelChanged();
    void activeSectionChanged();

private:
    Shared::Models::SectionModel* m_sectionModelPtr;
};
} // namespace Modules::Main

#endif // VIEW_H
