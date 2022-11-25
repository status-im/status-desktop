#pragma once

#include <QIdentityProxyModel>

class FigmaLinks;
class FigmaLinksModel;

class FigmaDecoratorModel : public QIdentityProxyModel
{
    Q_OBJECT
    Q_PROPERTY(FigmaLinks* figmaLinks READ getFigmaLinks
               WRITE setFigmaLinks NOTIFY figmaLinksChanged)
public:
    static constexpr auto FigmaRole = Qt::UserRole + 100;

    explicit FigmaDecoratorModel(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &proxyIndex, int role) const override;

    FigmaLinks* getFigmaLinks() const;
    void setFigmaLinks(FigmaLinks *figmaLinks);

    void setSourceModel(QAbstractItemModel *sourceModel) override;

signals:
    void figmaLinksChanged();

private:
    std::optional<int> m_titleRole;
    FigmaLinks* m_figmaLinks = nullptr;
    mutable QMap<QString, FigmaLinksModel*> m_submodels;
};
