import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Platform 0.1

import Sandbox 0.1

Column {
    spacing: 8

    StatusMacNotification {
        name: "Some name"
        message: "Some message here"
    }
}
