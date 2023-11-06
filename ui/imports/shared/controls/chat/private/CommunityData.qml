import QtQuick 2.15

QtObject {
    property string name
    property string description
    property string banner
    property string image
    property string color
    property int    membersCount
    property int    activeMembersCount // -1 when not available. >= 0 otherwise.
    readonly property bool activeMembersCountAvailable: activeMembersCount >= 0
}
