#include "pagesmodel.h"

#include <QFileInfo>
#include <QRegularExpression>

#include "directoryfileswatcher.h"

namespace {
const auto categoryUncategorized QStringLiteral("Uncategorized");
}

PagesModel::PagesModel(const QString &path, QObject *parent)
    : QAbstractListModel{parent}, m_path{path},
      m_pagesWatcher(new DirectoryFilesWatcher(
                         path, QStringLiteral("*Page.qml"), this))
{
    m_items = readMetadata(m_pagesWatcher->files());

    for (const auto& item : std::as_const(m_items))
        setFigmaLinks(item.title, item.figmaLinks);

    connect(m_pagesWatcher, &DirectoryFilesWatcher::filesChanged,
            this, &PagesModel::onPagesChanged);
}

PagesModelItem PagesModel::readMetadata(const QString& path)
{
    PagesModelItem item;
    item.path = path;
    item.title = QFileInfo(path).fileName().chopped(
                (QStringLiteral("Page.qml").size()));

    QFile file(path);
    file.open(QIODevice::ReadOnly);
    QByteArray content = file.readAll();

    item.category = extractCategory(content);
    item.status = extractStatus(content);
    item.figmaLinks = extractFigmaLinks(content);

    return item;
}

QList<PagesModelItem> PagesModel::readMetadata(const QStringList &paths)
{
    QList<PagesModelItem> metadata;
    metadata.reserve(paths.size());

    std::transform(paths.begin(), paths.end(), std::back_inserter(metadata),
                   [](auto& path) {
        return readMetadata(path);
    });

    return metadata;
}

QString PagesModel::extractCategory(const QByteArray& content)
{
    static QRegularExpression categoryRegex(
                "^//(\\s)*category:(.+)$", QRegularExpression::MultilineOption);

    QRegularExpressionMatch categoryMatch = categoryRegex.match(content);
    QString category = categoryMatch.hasMatch()
            ? categoryMatch.captured(2).trimmed() : categoryUncategorized;

    return category.isEmpty() ? categoryUncategorized : category;
}

PagesModel::Status PagesModel::extractStatus(const QByteArray& content)
{
    static QRegularExpression statusRegex(
                "^//(\\s)*status:(.+)$", QRegularExpression::MultilineOption);

    QRegularExpressionMatch statusMatch = statusRegex.match(content);
    QString status = statusMatch.hasMatch()
            ? statusMatch.captured(2).trimmed() : "";

    if (status == QStringLiteral("bad"))
        return Bad;
    if (status == QStringLiteral("decent"))
        return Decent;
    if (status == QStringLiteral("good"))
        return Good;

    return Uncategorized;
}

QStringList PagesModel::extractFigmaLinks(const QByteArray& content)
{
    static QRegularExpression figmaRegex(
                "^(\\/\\/\\s*)((?:https:\\/\\/)?(?:www\\.)?figma\\.com\\/.*)$",
                QRegularExpression::MultilineOption);

    QRegularExpressionMatchIterator i = figmaRegex.globalMatch(content);
    QStringList links;

    while (i.hasNext()) {
        QRegularExpressionMatch match = i.next();
        QString link = match.captured(2);
        links << link;
    }

    return links;
}

void PagesModel::onPagesChanged(const QStringList& added,
                                const QStringList& removed,
                                const QStringList& changed)
{
    for (auto& path : removed) {
        auto index = getIndexByPath(path);

        beginRemoveRows({}, index, index);
        m_items.removeAt(index);
        endRemoveRows();
    }

    if (added.size()) {
        beginInsertRows({}, rowCount(), rowCount() + added.size() - 1);

        auto metadata = readMetadata(added);

        for (const auto& item : std::as_const(metadata))
            setFigmaLinks(item.title, item.figmaLinks);

        m_items << metadata;
        endInsertRows();
    }

    for (auto& path : changed) {
        auto index = getIndexByPath(path);
        const auto& previous = m_items.at(index);

        PagesModelItem metadata = readMetadata(path);
        setFigmaLinks(metadata.title, metadata.figmaLinks);

        // For simplicity category and status change is handled by removing and
        // adding item. In the future it can be changed to regular dataChanged
        // event and handled properly in upstream models like SectionSDecoratorModel.
        if (previous.category != metadata.category
                || previous.status != metadata.status) {
            beginRemoveRows({}, index, index);
            m_items.removeAt(index);
            endRemoveRows();

            beginInsertRows({}, rowCount(), rowCount());
            m_items << metadata;
            endInsertRows();
        }
    }
}

int PagesModel::getIndexByPath(const QString& path) const
{
    auto it = std::find_if(m_items.begin(), m_items.end(), [&path](auto& it) {
        return it.path == path;
    });
    assert(it != m_items.end());
    return std::distance(m_items.begin(), it);
}

QHash<int, QByteArray> PagesModel::roleNames() const
{
    static const QHash<int,QByteArray> roles {
        { TitleRole, QByteArrayLiteral("title") },
        { CategoryRole, QByteArrayLiteral("category") },
        { StatusRole, QByteArrayLiteral("status") },
        { FigmaRole, QByteArrayLiteral("figma") }
    };

    return roles;
}

int PagesModel::rowCount(const QModelIndex &parent) const
{
    return m_items.length();
}

QVariant PagesModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid))
        return {};

    if (role == TitleRole)
        return m_items.at(index.row()).title;

    if (role == CategoryRole)
        return m_items.at(index.row()).category;

    if (role == StatusRole)
        return m_items.at(index.row()).status;

    if (role == FigmaRole) {
        auto title = m_items.at(index.row()).title;
        auto it = m_figmaSubmodels.find(title);
        assert(it != m_figmaSubmodels.end());

        return QVariant::fromValue(it.value());
    }

    return {};
}

void PagesModel::setFigmaLinks(const QString& title, const QStringList& links)
{
    auto it = m_figmaSubmodels.find(title);

    if (it == m_figmaSubmodels.end()) {
        m_figmaSubmodels.insert(title, new FigmaLinksModel(links, this));
    } else {
        it.value()->setContent(links);
    }
}
