#pragma once
#include <QAbstractListModel>
#include <QQmlEngine>

namespace Status::Helpers {

/// Generic typed QObject provider model
///
/// Supports: source model update
/// \todo rename it to SharedQObjectVectorModel
/// \todo consider "separating class template interface and implementation: move impl to .hpp file and include it at the end of .h file. That's not affect compilation time, but it better to read" propsed by @MishkaRogachev
template<typename T>
class QObjectVectorModel final : public QAbstractListModel
{
    static_assert(std::is_base_of<QObject, T>::value, "Template parameter (T) not a QObject");

public:

    using ObjectContainer = std::vector<std::shared_ptr<T>>;

    explicit QObjectVectorModel(ObjectContainer initialObjects, const char* objectRoleName, QObject* parent = nullptr)
        : QAbstractListModel(parent)
        , m_objects(std::move(initialObjects))
        , m_roleName(objectRoleName)
    {
    }
    explicit QObjectVectorModel(const char* objectRoleName, QObject* parent = nullptr)
        : QObjectVectorModel(ObjectContainer{}, objectRoleName, parent)
    {}
    ~QObjectVectorModel() {};

    QHash<int, QByteArray> roleNames() const override {
        return {{ObjectRole, m_roleName}};
    };

    virtual int rowCount(const QModelIndex& parent = QModelIndex()) const override {
        Q_UNUSED(parent)
        return m_objects.size();
    }

    virtual QVariant data(const QModelIndex& index, int role) const override {
        if(!QAbstractItemModel::checkIndex(index) || role != ObjectRole)
            return QVariant();

        return QVariant::fromValue<QObject*>(m_objects[index.row()].get());
    }

    const T* at(size_t pos) const {
        return m_objects.at(pos).get();
    };

    std::shared_ptr<T> get(size_t pos) {
        return m_objects.at(pos);
    };

    size_t size() const {
        return m_objects.size();
    };

    void clear() {
        m_objects.clear();
    };

    void push_back(const std::shared_ptr<T> newValue) {
        beginInsertRows(QModelIndex(), m_objects.size(), m_objects.size());
        m_objects.push_back(newValue);
        endInsertRows();
    };

    void resize(size_t count) {
        if(count > m_objects.size()) {
            beginInsertRows(QModelIndex(), m_objects.size(), count - 1);
            m_objects.resize(count);
            endInsertRows();
        }
        else if(count < m_objects.size()) {
            beginRemoveRows(QModelIndex(), count, m_objects.size() - 1);
            m_objects.resize(count);
            endRemoveRows();
        }
    };

    void set(size_t row, const std::shared_ptr<T> newVal) {
        m_objects.at(row) = newVal;
        emit dataChanged(index(row), index(row), {});
    };

    const ObjectContainer &objects() const { return m_objects; };

private:
    ObjectContainer m_objects;

    const QByteArray m_roleName;

    constexpr static auto ObjectRole = Qt::UserRole + 1;
};

}
