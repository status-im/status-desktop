#include <MockQObject.h>
#include <Global.h>
#include <QMetaType>

using namespace std;

namespace {
std::string toStringFromQVariant(DosQVariant *variant)
{
    CharPointer charArray(dos_qvariant_toString(variant), &dos_chararray_delete);
    return std::string(charArray.get());
}

VoidPointer initializeMetaObject()
{
    VoidPointer superClassMetaObject(dos_qobject_qmetaobject(), &dos_qmetaobject_delete);
    // Signals
    ::SignalDefinition signalDefinitionArray[2];

    // nameChanged
    ParameterDefinition nameChanged[1];
    nameChanged[0].name = "name";
    nameChanged[0].metaType = QMetaType::QString;
    signalDefinitionArray[0].name = "nameChanged";
    signalDefinitionArray[0].parametersCount = 1;
    signalDefinitionArray[0].parameters = nameChanged;

    // arrayPropertyChanged
    ParameterDefinition arrayPropertyChanged[1];
    arrayPropertyChanged[0].metaType = QMetaType::QVariantList;
    arrayPropertyChanged[0].name = "arrayProperty";
    signalDefinitionArray[1].name = "arrayPropertyChanged";
    signalDefinitionArray[1].parametersCount = 1;
    signalDefinitionArray[1].parameters = arrayPropertyChanged;

    ::SignalDefinitions signalDefinitions;
    signalDefinitions.count = 2;
    signalDefinitions.definitions = signalDefinitionArray;

    // Slots
    ::SlotDefinition slotDefinitionArray[4];

    slotDefinitionArray[0].name = "name";
    slotDefinitionArray[0].returnMetaType = QMetaType::QString;
    slotDefinitionArray[0].parametersCount = 0;
    slotDefinitionArray[0].parameters = nullptr;

    ParameterDefinition setNameParameters[1];
    setNameParameters[0].metaType = QMetaType::QString;
    setNameParameters[0].name = "name";
    slotDefinitionArray[1].name = "setName";
    slotDefinitionArray[1].returnMetaType = QMetaType::Void;
    slotDefinitionArray[1].parametersCount = 1;
    slotDefinitionArray[1].parameters = setNameParameters;

    slotDefinitionArray[2].name = "arrayProperty";
    slotDefinitionArray[2].returnMetaType = QMetaType::QVariantList;
    slotDefinitionArray[2].parametersCount = 0;
    slotDefinitionArray[2].parameters = nullptr;

    ParameterDefinition setArrayPropertyParameters[1];
    setArrayPropertyParameters[0].metaType = QMetaType::QVariantList;
    setArrayPropertyParameters[0].name = "arrayProperty";
    slotDefinitionArray[3].name = "setArrayProperty";
    slotDefinitionArray[3].returnMetaType = QMetaType::Void;
    slotDefinitionArray[3].parametersCount = 1;
    slotDefinitionArray[3].parameters = setArrayPropertyParameters;

    ::SlotDefinitions slotDefinitions;
    slotDefinitions.count = 4;
    slotDefinitions.definitions = slotDefinitionArray;

    // Properties
    ::PropertyDefinition propertyDefinitionArray[2];
    propertyDefinitionArray[0].name = "name";
    propertyDefinitionArray[0].notifySignal = "nameChanged";
    propertyDefinitionArray[0].propertyMetaType = QMetaType::QString;
    propertyDefinitionArray[0].readSlot = "name";
    propertyDefinitionArray[0].writeSlot = "setName";

    propertyDefinitionArray[1].name = "arrayProperty";
    propertyDefinitionArray[1].notifySignal = "arrayPropertyChanged";
    propertyDefinitionArray[1].propertyMetaType = QMetaType::QVariantList;
    propertyDefinitionArray[1].readSlot = "arrayProperty";
    propertyDefinitionArray[1].writeSlot = "setArrayProperty";

    ::PropertyDefinitions propertyDefinitions;
    propertyDefinitions.count = 2;
    propertyDefinitions.definitions = propertyDefinitionArray;

    return VoidPointer(dos_qmetaobject_create(superClassMetaObject.get(), "MockQObject", &signalDefinitions, &slotDefinitions, &propertyDefinitions),
                       &dos_qmetaobject_delete);
}
}


MockQObject::MockQObject()
    : m_vptr(dos_qobject_create(this, metaObject(), &onSlotCalled), &dos_qobject_delete)
    , m_arrayProperty(std::make_tuple(10, 5.3, false))
{}

MockQObject::~MockQObject() = default;

DosQMetaObject *MockQObject::staticMetaObject()
{
    static VoidPointer result = initializeMetaObject();
    return result.get();
}

::DosQMetaObject *MockQObject::metaObject()
{
    return staticMetaObject();
}

std::string MockQObject::objectName() const
{
    CharPointer result (dos_qobject_objectName(m_vptr.get()), &dos_chararray_delete);
    return string(result.get());
}

void MockQObject::setObjectName(const string &objectName)
{
    dos_qobject_setObjectName(m_vptr.get(), objectName.c_str());
}

::DosQObject *MockQObject::data()
{
    return m_vptr.get();
}

void MockQObject::swapData(VoidPointer &data)
{
    std::swap(m_vptr, data);
}

std::string MockQObject::name() const
{
    return m_name;
}

void MockQObject::setName(const string &name)
{
    if (name == m_name)
        return;
    m_name = name;
    nameChanged(name);
}

void MockQObject::nameChanged(const string &name)
{
    int argc = 1;
    DosQVariant *argv[1];
    argv[0] = dos_qvariant_create_string(name.c_str());
    dos_qobject_signal_emit(m_vptr.get(), "nameChanged", argc, argv);
    dos_qvariant_delete(argv[0]);
}

std::tuple<int, double, bool> MockQObject::arrayProperty() const
{
    return m_arrayProperty;
}

void MockQObject::setArrayProperty(std::tuple<int, double, bool> value)
{
    if (m_arrayProperty == value)
        return;
    m_arrayProperty = std::move(value);
    arrayPropertyChanged(value);
}

void MockQObject::arrayPropertyChanged(const std::tuple<int, double, bool> &value)
{
    std::vector<DosQVariant *> valueAsDosQVariant ({
        dos_qvariant_create_int(std::get<0>(value)),
        dos_qvariant_create_double(std::get<1>(value)),
        dos_qvariant_create_bool(std::get<2>(value))
    });

    int argc = 1;
    DosQVariant *argv[1];
    argv[0] = dos_qvariant_create_array(valueAsDosQVariant.size(), &valueAsDosQVariant[0]);
    dos_qobject_signal_emit(m_vptr.get(), "arrayPropertyChanged", argc, argv);
    dos_qvariant_delete(argv[0]);
    std::for_each(valueAsDosQVariant.begin(), valueAsDosQVariant.end(), &dos_qvariant_delete);
}

void MockQObject::onSlotCalled(void *selfVPtr, DosQVariant *dosSlotNameVariant, int dosSlotArgc, DosQVariant **dosSlotArgv)
{
    MockQObject *self = static_cast<MockQObject *>(selfVPtr);

    string slotName = toStringFromQVariant(dosSlotNameVariant);
    if (slotName == "name") {
        VoidPointer name(dos_qvariant_create_string(self->name().c_str()), &dos_qvariant_delete);
        dos_qvariant_assign(dosSlotArgv[0], name.get());
        return;
    }

    if (slotName == "setName") {
        self->setName(toStringFromQVariant(dosSlotArgv[1]));
        return;
    }

    if (slotName == "arrayProperty") {
        auto value = self->arrayProperty();

        std::vector<DosQVariant *> data {
            dos_qvariant_create_int(std::get<0>(value)),
            dos_qvariant_create_double(std::get<1>(value)),
            dos_qvariant_create_bool(std::get<2>(value))
        };
        VoidPointer arrayProperty(dos_qvariant_create_array(data.size(), &data[0]), &dos_qvariant_delete);
        dos_qvariant_assign(dosSlotArgv[0], arrayProperty.get());
        std::for_each(data.begin(), data.end(), &dos_qvariant_delete);
        return;
    }

    if (slotName == "setArrayProperty") {
        std::tuple<int, double, bool> value;
        DosQVariantArray *array = dos_qvariant_toArray(dosSlotArgv[1]);
        std::get<0>(value) = dos_qvariant_toInt(array->data[0]);
        std::get<1>(value) = dos_qvariant_toDouble(array->data[1]);
        std::get<2>(value) = dos_qvariant_toBool(array->data[2]);
        dos_qvariantarray_delete(array);
        self->setArrayProperty(std::move(value));
        return;
    }
}
