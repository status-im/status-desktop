#include "pagesmodel.h"

#include <QDir>
#include <QFileSystemWatcher>
#include <QRegularExpression>

#include <unordered_map>

namespace {
const auto categoryUncategorized QStringLiteral("Uncategorized");
}

PagesModel::PagesModel(const QString &path, QObject *parent)
    : QAbstractListModel{parent}, m_path{path},
      fsWatcher(new QFileSystemWatcher(this))
{
    m_items = load();
    readMetadata(m_items);

    for (const auto& item : qAsConst(m_items)) {
        setFigmaLinks(item.title, item.figmaLinks);
    }

    fsWatcher->addPath(path);

    connect(fsWatcher, &QFileSystemWatcher::directoryChanged,
            this, &PagesModel::reload);
}

QList<PagesModelItem> PagesModel::load() const {
    static QRegularExpression fileNameRegex(
                QRegularExpression::anchoredPattern("(.*)Page\\.qml"));

    QDir dir(m_path);
    dir.setFilter(QDir::Files);

    const QFileInfoList files = dir.entryInfoList();
    QList<PagesModelItem> items;

    std::for_each(files.begin(), files.end(), [this, &items] (auto &fileInfo) {
        QString fileName = fileInfo.fileName();
        QRegularExpressionMatch fileNameMatch = fileNameRegex.match(fileName);

        if (!fileNameMatch.hasMatch())
            return;

        PagesModelItem item;
        item.path = fileInfo.filePath();
        item.title = fileNameMatch.captured(1);
        item.lastModified = fileInfo.lastModified();

        items << item;
    });

    return items;
}

void PagesModel::readMetadata(PagesModelItem& item) {
    static QRegularExpression categoryRegex(
                "^//(\\s)*category:(.+)$", QRegularExpression::MultilineOption);

    QFile file(item.path);
    file.open(QIODevice::ReadOnly);
    QByteArray content = file.readAll();

    QRegularExpressionMatch categoryMatch = categoryRegex.match(content);
    QString category = categoryMatch.hasMatch()
            ? categoryMatch.captured(2).trimmed() : categoryUncategorized;

    item.category = category;

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

    item.figmaLinks = links;
}

void PagesModel::readMetadata(QList<PagesModelItem> &items) {
    std::for_each(items.begin(), items.end(), [](auto&item) {
        readMetadata(item);
    });
}

void PagesModel::reload() {
    const QList<PagesModelItem> currentItems = load();
    std::unordered_map<QString, PagesModelItem> mapping;

    for (const PagesModelItem &item : qAsConst(m_items))
        mapping[item.title] = item;

    std::vector<PagesModelItem> newItems;
    std::vector<PagesModelItem> changedItems;
    std::vector<PagesModelItem> removedItems;

    for (const auto &item : currentItems) {
        auto it = mapping.find(item.title);

        if (it == mapping.end()) {
            newItems.push_back(item);
        } else {
            if (item.lastModified != it->second.lastModified)
                changedItems.push_back(item);

            mapping.erase(it);
        }
    }

    for (const auto& [key, value] : mapping)
        removedItems.push_back(value);

    for (auto& item : removedItems) {

        auto it = std::find_if(m_items.begin(), m_items.end(), [&item](auto& it){
            return it.title == item.title;
        });

        auto index = std::distance(m_items.begin(), it);

        beginRemoveRows(QModelIndex{}, index, index);
        m_items.removeAt(index);
        endRemoveRows();
    }

    if (newItems.size()) {
        beginInsertRows(QModelIndex{}, rowCount(), rowCount() + newItems.size() - 1);

        for (auto& item : newItems) {
            readMetadata(item);
            m_items << item;
        }

        endInsertRows();
    }

    for (auto& item : changedItems) {
        auto it = std::find_if(m_items.begin(), m_items.end(), [&item](auto& it){
            return it.title == item.title;
        });

        auto index = std::distance(m_items.begin(), it);
        const auto& previous = *it;
        readMetadata(item);
        setFigmaLinks(item.title, item.figmaLinks);

        if (previous.category != item.category) {
            // For simplicity category change is handled by removing and
            // adding item. In the future it can be changed to regular dataChanged
            // event and handled properly in upstream models like SectionSDecoratorModel.
            beginRemoveRows(QModelIndex{}, index, index);
            m_items.removeAt(index);
            endRemoveRows();

            beginInsertRows(QModelIndex{}, rowCount(), rowCount());
            m_items << item;
            endInsertRows();
        }
    }
}

QHash<int, QByteArray> PagesModel::roleNames() const
{
    static const QHash<int,QByteArray> roles {
        { TitleRole, QByteArrayLiteral("title") },
        { CategoryRole, QByteArrayLiteral("category") },
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
