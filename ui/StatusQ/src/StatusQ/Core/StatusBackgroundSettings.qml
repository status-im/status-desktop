import QtQuick 2.14

QtObject {
    id: statusBackgroundSettings

    property int width
    property int height
    property int radius
    property int borderWidth

    property StatusColorSettings color: StatusColorSettings {}
    property StatusColorSettings borderColor: StatusColorSettings {}
}
