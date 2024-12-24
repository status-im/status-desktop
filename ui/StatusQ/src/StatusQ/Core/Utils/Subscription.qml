import QtQuick 2.15

QtObject {
    id: root
    
    readonly property string subscriptionId: Utils.uuid()
    
    property bool isReady: false
    //The topic to subscribe to
    property string topic: ""
    property var response: {}
}
