#include "pagesmodel.h"

#include <QRegularExpression>
#include <QDir>

namespace {
const auto categoryUncategorized QStringLiteral("Uncategorized");
}

PagesModel::PagesModel(const QString &path, QObject *parent)
    : QAbstractListModel{parent}
{
    QDir dir(path);
    dir.setFilter(QDir::Files);

    static QRegularExpression fileNameRegex(
                QRegularExpression::anchoredPattern("(.*)Page\\.qml"));
    static QRegularExpression categoryRegex(
                "^//(\\s)*category:(.+)$", QRegularExpression::MultilineOption);

    const QFileInfoList files = dir.entryInfoList();

    std::for_each(files.begin(), files.end(), [this] (auto &fileInfo) {
        QString fileName = fileInfo.fileName();
        QRegularExpressionMatch fileNameMatch = fileNameRegex.match(fileName);

        if (!fileNameMatch.hasMatch())
            return;

        QFile file(fileInfo.filePath());
        file.open(QIODevice::ReadOnly);
        QByteArray content = file.readAll();

        QRegularExpressionMatch categoryMatch = categoryRegex.match(content);
        QString category = categoryMatch.hasMatch()
                ? categoryMatch.captured(2).trimmed() : categoryUncategorized;

        QString title = fileNameMatch.captured(1);
        m_items << PagesModelItem { title, category };
    });
}

QHash<int, QByteArray> PagesModel::roleNames() const
{
    static const QHash<int,QByteArray> roles {
        { TitleRole, QByteArrayLiteral("title") },
        { CategoryRole, QByteArrayLiteral("category") }
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

    return {};
}
