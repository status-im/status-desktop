import QtQuick 2.15

QtObject {
    property string name
    property string description
    property string emoji 
    property string color
    readonly property CommunityData communityData: CommunityData {}
}
