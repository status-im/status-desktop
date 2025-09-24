#pragma once

#include <QAbstractListModel>

struct LanguageData {
    QString code, fullIsoCode, name, nativeName;
};

class LanguageModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QStringList languageCodes READ languageCodes WRITE setLanguageCodes NOTIFY languageCodesChanged REQUIRED FINAL)

public:
    enum LanguageDataRoles {
        CodeRole = Qt::UserRole + 1,
        FullIsoCode,
        NameRole,
        NativeNameRole,
    };
    Q_ENUM(LanguageDataRoles)

    explicit LanguageModel(QObject* parent = nullptr);
    explicit LanguageModel(const QStringList &languageCodes, QObject* parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;

signals:
    void languageCodesChanged();

private:
    QList<LanguageData> m_data;

    QStringList languageCodes() const;
    void setLanguageCodes(const QStringList &newLanguageCodes);
    QStringList m_languageCodes;

    void rebuildModel();
};
