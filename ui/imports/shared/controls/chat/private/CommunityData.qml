import QtQuick

QtObject {
    property string name
    property string description
    property string banner
    property string image
    property string color
    property int    membersCount
    property int    activeMembersCount // -1 when not available. >= 0 otherwise.
    property bool   encrypted
    property bool   joined
    readonly property bool activeMembersCountAvailable: activeMembersCount >= 0
}
