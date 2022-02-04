import QtQuick 2.14

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root
    width: 800
    height: 100

    //Simulate animation between steps
    property bool stepsCompleted: false
    function reset() {
        for (var i = 0; i < stepsListModel.count; i++) {
            stepsListModel.setProperty(i, "loading", false);
            stepsListModel.setProperty(i, "stepCompleted", false);
            step1.loadingTime = 0;
            step2.loadingTime = 0;
            root.stepsCompleted = false;
        }
    }

    ListModel {
        id: stepsListModel
        ListElement {description:"Send Request"; loadingTime: 0; stepCompleted: false}
        ListElement {description:"Receive Response"; loadingTime: 0; stepCompleted: false}
        ListElement {description:"Confirm Identity"; loadingTime: 0; stepCompleted: false}
    }

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: {
            if (!root.stepsCompleted) {
                animate.running = true;
            } else {
                root.reset();
            }
        }
    }

    StatusBaseText {
        id: indicLabel
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.palette.directColor1
        text: "Press Ctrl+R to run the animation"
        font.pixelSize: 17
    }

    SequentialAnimation {
        id: animate
        ScriptAction {
            id: step1
            property int loadingTime: 0
            Behavior on loadingTime { NumberAnimation { duration: 2000 }}
            onLoadingTimeChanged: {
                stepsListModel.setProperty(1, "loadingTime", step1.loadingTime);
            }
            script: {
                step1.loadingTime = 2000;
                stepsListModel.setProperty(0, "loadingTime", step1.loadingTime);
                stepsListModel.setProperty(0, "stepCompleted", true);
            }
        }
        PauseAnimation {
            duration: 2100
        }
        ScriptAction {
            id: step2
            property int loadingTime: 0
            Behavior on loadingTime { NumberAnimation { duration: 2000 } }
            onLoadingTimeChanged: {
                stepsListModel.setProperty(2, "loadingTime", step2.loadingTime);
            }
            script: {
                step2.loadingTime = 2000;
                stepsListModel.setProperty(1, "stepCompleted", true);
            }
        }
        PauseAnimation {
            duration: 2100
        }
        ScriptAction {
            script: {
                stepsListModel.setProperty(2, "stepCompleted", true);
                root.stepsCompleted = true;
            }
        }
    }
    //simulation code

    StatusWizardStepper {
        id: wizardStepper
        width: (parent.width - 50)
        anchors.top: indicLabel.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        stepsModel: stepsListModel
    }
}
