import QtQuick 2.14
import "../../../../imports"
import "../../../../shared"

StyledText {
    id: dateTimeRoot
    color: Style.current.secondaryText
    font.pixelSize: Style.current.primaryTextFontSize

    readonly property string format_hhmm: "hh:mm"
    readonly property string format_hhmmss: "hh:mm:ss"
    readonly property string format_ddM: "ddM"
    readonly property string format_ddMyyyy: "ddMyyyy"
    readonly property string format_ddMyyyy_hhmm: "ddMyyyy hh:mm"

    readonly property var monthNames:[
        qsTr("January"),
        qsTr("February"),
        qsTr("March"),
        qsTr("April"),
        qsTr("May"),
        qsTr("June"),
        qsTr("July"),
        qsTr("August"),
        qsTr("September"),
        qsTr("October"),
        qsTr("November"),
        qsTr("December")
    ]

    property string timestamp: ""
    property string selectedFormat: ""

    text: {
        if(dateTimeRoot.timestamp === "")
            return ""

        let d = new Date(parseInt(dateTimeRoot.timestamp, 10) * 1000)

        let hrs = d.getHours() < 10? "0" + d.getHours() : d.getHours()
        let mins = d.getMinutes() < 10? "0" + d.getMinutes() : d.getMinutes()
        let secs = d.getSeconds() < 10? "0" + d.getSeconds() : d.getSeconds()
        let month = monthNames[d.getMonth()]

        //////////////////////////////////////////////////////////
        // Using options in `toLocaleString` is a way easier, but from some reason that doesn't work with 'default' locale.
        // We should update this once we are able to have e.g. 'en_US' instead of 'en' from `globalSettings.locale`
        // in that case we will write something like this:
        //
        // return d.toLocaleString('default', { day: '2-digit', month: 'long', year: 'numeric', hour: '2-digit', minute:'2-digit'})
        //
        // Till then we're forced to do it manually.
        //////////////////////////////////////////////////////////

        if(dateTimeRoot.selectedFormat === dateTimeRoot.format_hhmm)
            return hrs + ":" + mins
        else if(dateTimeRoot.selectedFormat === dateTimeRoot.format_hhmmss)
            return hrs + ":" + mins + ":" + secs
        else if(dateTimeRoot.selectedFormat === dateTimeRoot.format_ddM)
            return d.getDate() + " " + month
        else if(dateTimeRoot.selectedFormat === dateTimeRoot.format_ddMyyyy)
            return d.getDate() + " " + month + " " + d.getFullYear()
        else if(dateTimeRoot.selectedFormat === dateTimeRoot.format_ddMyyyy_hhmm)
            return d.getDate() + " " + month + " " + d.getFullYear() + " " + hrs + ":" + mins + ":" + secs

        return d.toISOString()
    }
}
