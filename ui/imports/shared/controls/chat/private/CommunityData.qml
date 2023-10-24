import QtQuick 2.15

QtObject {
    property string name
    property string description
    property string banner
    property string image
    property string color
    property int    membersCount
    property int    activeMembersCount: -1 // TODO: implement this and remove the magic number
}
