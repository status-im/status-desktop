#pragma once

#include <tuple>
#include <Global.h>

class MockQObject
{
public:
    MockQObject();
    virtual ~MockQObject();

    static ::DosQMetaObject *staticMetaObject();
    virtual ::DosQMetaObject *metaObject();

    ::DosQObject *data();
    void swapData(VoidPointer &data);

    std::string objectName() const;
    void setObjectName(const std::string &objectName);

    std::string name() const;
    void setName(const std::string &name);
    void nameChanged(const std::string &name);

    std::tuple<int, double, bool> arrayProperty() const;
    void setArrayProperty(std::tuple<int, double, bool> value);
    void arrayPropertyChanged(const std::tuple<int, double, bool> &value);

private:
    static void onSlotCalled(void *selfVPtr, DosQVariant *dosSlotNameVariant, int dosSlotArgc, DosQVariant **dosSlotArgv);

    VoidPointer m_vptr;
    std::string m_name;
    std::tuple<int, double, bool> m_arrayProperty;
};
