import QtQuick 2.12

import utils 1.0
//import Qt.labs.lottieqt 1.0

Item {
    id: root
    anchors.fill: parent
    visible: (opacity > 0.0001)
    Behavior on opacity { NumberAnimation { duration: 250 }}

    Timer {
        running: true
        interval: 2000
        onTriggered: {
            root.opacity = 0.0;
        }
    }

    Image {
        width: 150
        height: 150
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        source: Style.svg("status-logo-circle")
    }

//    LottieAnimation {
//        anchors.centerIn: parent
//        autoPlay: false
//        loops: LottieAnimation.Infinite
//        quality: LottieAnimation.MediumQuality
//        source: Style.lottie("status_splash")
//        onStatusChanged: {
//            if (status === LottieAnimation.Ready) {
//                start();
//            }
//        }
//    }
}
