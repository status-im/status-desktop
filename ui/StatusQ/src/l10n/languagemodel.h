#pragma once

#include <QAbstractListModel>
#include <QLocale>

struct LanguageData {
    QString code, fullIsoCode, name, nativeName;
};

class LanguageModel : public QAbstractListModel
{
    Q_OBJECT

    ///< list of locally available translations (*.qm) as lang ISO codes
    Q_PROPERTY(QStringList languageCodes READ languageCodes WRITE setLanguageCodes NOTIFY languageCodesChanged REQUIRED FINAL)
    ///< Lokalise translation statistics, map of lang ISO codes to percent completed [langcode:string, percentage:int]
    Q_PROPERTY(QVariantMap lokalisedLanguageScores READ lokalisedLanguageScores WRITE setLokalisedLanguageScores NOTIFY lokalisedLanguageScoresChanged FINAL)

public:
    enum LanguageDataRoles {
        CodeRole = Qt::UserRole + 1,
        FullIsoCode,
        NameRole,
        NativeNameRole,
        PercentRole,
    };
    Q_ENUM(LanguageDataRoles)

    explicit LanguageModel(QObject* parent = nullptr);
    explicit LanguageModel(const QStringList &languageCodes, QObject* parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role) const override;

    Q_INVOKABLE QString formattedNativeLanguageName(const QString& code, const QLocale& loc) const;

signals:
    void languageCodesChanged();
    void lokalisedLanguageScoresChanged();

private:
    QList<LanguageData> m_data;

    QStringList languageCodes() const;
    void setLanguageCodes(const QStringList &newLanguageCodes);
    QStringList m_languageCodes;

    QVariantMap lokalisedLanguageScores() const;
    void setLokalisedLanguageScores(const QVariantMap &newLokalisedLanguageScores);
    QVariantMap m_lokalisedLanguageScores;

    void rebuildModel();
};
