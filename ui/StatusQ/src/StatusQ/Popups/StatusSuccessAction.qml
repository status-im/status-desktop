import QtQuick 2.14

import StatusQ.Popups 0.1

/*!
   \qmltype StatusSuccessAction
   \inherits StatusMenuItem
   \inqmlmodule StatusQ.Popups
   \since StatusQ.Popups 0.1
   \brief Menu action displaying success state.

   The \c StatusSuccessAction visually indicate a success state after being triggered.
   Success state is showed by changing action type to \c{Success}.

   \qml
        StatusSuccessAction.qml {
            text: qsTr("Copy details")
            successText: qsTr("Details copied")
        }
   \endqml

   By default this action doesn't close the menu. The \l{autoDismissMenu} can be enabled
   to enable this behavior.
*/

StatusMenuItem {
    id: root

    /*!
       \qmlproperty bool StatusSuccessAction.qml::success
       This property holds state of the action.
    */
    property bool success: false
    /*!
       \qmlproperty string StatusSuccessAction.qml::successText
       This property holds success text displayed on success state.

       Default value is binded to \c{text}.
    */
    property string successText: text
    /*!
       \qmlproperty string StatusSuccessAction.qml::successIconName
       This property holds icon name displayed on success state.

       Default value is \c{tiny/checkmark}.
    */
    property string successIconName: "tiny/checkmark"
    /*!
       \qmlproperty bool StatusSuccessAction.qml::autoDismissMenu
       This property enable menu closing on click.
    */
    property bool autoDismissMenu: false
    /*!
       \qmlproperty int StatusSuccessAction.qml::timeout
       This property controls how long success state is showed.
    */
    property int timeout: 2000

    /*! \internal Overriden signal to not close menu on click */
    signal triggered()

    onVisibleChanged: {
        if (!visible)
            success = false
    }
    Binding on text {
        when: root.success
        value: root.successText
    }
    action: StatusAction {
        type: root.success ? StatusAction.Type.Success : StatusAction.Type.Normal
        icon.name: root.success ? root.successIconName : root.icon.name
    }
    MouseArea {
        // NOTE Using mouse area to block menu auto closing
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            root.triggered()
            root.success = true
        }
    }
    Timer {
        id: debounceTimer
        interval: root.timeout
        running: root.success
        onTriggered: {
            root.success = false
            if (root.autoDismissMenu && root.menu) {
                root.menu.dismiss()
            }
        }
    }
}
