#include "persistentindexestester.h"
#include "StatusQ/snapshotmodel.h"

#include <QDebug>

PersistentIndexesTester::PersistentIndexesTester(QAbstractItemModel* model)
    : m_model(model)
{
    storeIndexesAndData();
}

PersistentIndexesTester::~PersistentIndexesTester() = default;

void PersistentIndexesTester::storeIndexesAndData()
{
    if (m_model == nullptr) {
        qWarning() << "PersistentIndexesTester: model cannot be null.";
        return;
    }

    m_snapshot = std::make_unique<SnapshotModel>(*m_model);

    const int count = m_model->rowCount();
    m_persistentIndexes.clear();
    m_persistentIndexes.reserve(count);

    for (auto i = 0; i < count; i++)
        m_persistentIndexes << m_model->index(i, 0);
}

bool PersistentIndexesTester::compare()
{
    if (m_model == nullptr) {
        qWarning() << "PersistentIndexesTester: model cannot be null.";
        return false;
    }

    const auto count = m_model->rowCount();
    const auto roles = m_model->roleNames().keys();

    for (auto i = 0; i < count; i++) {

        const auto idx = m_persistentIndexes[i];

        for (auto role : roles) {
            if (idx.data(role) != m_snapshot->data(i, role)) {
                auto roleName = QString::fromUtf8(m_model->roleNames()
                                                  .value(role));

                qWarning() << QString("Mismatch detected. Persistent index "
                                      "data: %1, snapshot data: %2, idx: %3, "
                                      "role: %4")
                              .arg(idx.data(role).toString(),
                                   m_snapshot->data(i, role).toString(),
                                   QString::number(i), roleName);
                return false;
            }
        }
    }

    return true;
}
