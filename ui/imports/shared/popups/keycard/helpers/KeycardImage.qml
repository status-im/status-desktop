import QtQuick 2.14

import utils 1.0

Item {
    id: root

    property url source: ""
    property string pattern: ""
    property int startImgIndexForTheFirstLoop: 0
    property int startImgIndexForOtherLoops: 0
    property int endImgIndex: 0
    property int duration: 0
    property int loops: -1 // infinite

    signal animationCompleted()

    QtObject {
        id: d

        property int currentLoop: 1
        property bool isAnimation: false

        function restart() {
            d.currentLoop = 1
            animation.from = root.startImgIndexForTheFirstLoop
            animation.to = root.endImgIndex
            animation.duration = root.duration
            img.currentImgIndex = root.startImgIndexForTheFirstLoop
            if (d.isAnimation)
                animation.restart()
        }
    }

    onPatternChanged: {
        d.isAnimation = root.duration > 0 && root.pattern !== ""
        d.restart()
    }

    onStartImgIndexForTheFirstLoopChanged: {
        d.restart()
    }

    onEndImgIndexChanged: {
        d.restart()
    }

    onDurationChanged: {
        d.isAnimation = root.duration > 0 && root.pattern !== ""
        d.restart()
    }

    Image {
        id: img
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        mipmap: true
        source: d.isAnimation?
                    Style.png(root.pattern.arg(img.currentImgIndex)) :
                    root.source

        property int currentImgIndex: root.startImgIndexForTheFirstLoop

        onCurrentImgIndexChanged: {
            if (currentImgIndex == root.endImgIndex) {

                if (d.currentLoop === root.loops && root.loops > -1) {
                    animation.stop()
                    root.animationCompleted()
                    return
                }
                if (d.currentLoop === 1 && (root.loops === -1 || root.loops > 1)) {
                    animation.stop()
                    animation.duration = root.duration / (root.endImgIndex + 1) * (root.endImgIndex - root.startImgIndexForOtherLoops)
                    animation.from = root.startImgIndexForOtherLoops
                    animation.to = root.endImgIndex
                    animation.loops = root.loops == -1? Animation.Infinite : root.loops
                    animation.start()
                }

                d.currentLoop += 1
            }
        }

        NumberAnimation on currentImgIndex {
            id: animation
            from: root.startImgIndexForTheFirstLoop
            to: root.endImgIndex
            duration: root.duration
        }
    }
}
