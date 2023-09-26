import QtQuick 2.14

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0


/* This component will format the urls in TextEdit and add the proper anchor tags
   It receives the TextEdit component and the urls model containing the urls to format. The URL detection needs to be done outside of this component

   Due to the Qt limitations (the undo stack is cleared when editing the internal formatted text) this component will install a custom undo stack manager.
*/

QtObject {
    id: root

    /* The TextEdit component containing the text to format
       The textEdit is required to be able to access the text and the cursor position
    */
    required property TextEdit textEdit
    /* The url to highlight
       The url is required to be able to highlight URLs
    */
    required property string highlightUrl
    /* The model containing the urls to format
       All the urls in the model will be formatted
       Eg: [ { url: "https://www.google.com" }, { url: "https://www.google.ro" } ]
    */
    required property var urlModel

    property bool enabled: true

    /* Custom undo stack manager. This is needed because the hyperlinks formatter will alter the internal rich text of the TextEdit
       and the standard undo stack manager will clear the stack on each change.
    */
    readonly property UndoStackManager undoStackManager: UndoStackManager {
        textEdit: root.textEdit
        enabled: root.enabled
    }

    /* Internal component to format the hyperlinks
       This component is used to format the hyperlinks and add the proper anchor tags
    */
    readonly property Instantiator handlers: Instantiator {
        id: hyperlinksFormatter

        readonly property string selectLinkBetweenAnchors: `<a href="%1".*?<span.*?>(.*?)<\/span><\/a>`
        readonly property string selectLinkWithoutAnchors: "%1(?=<| )(?![^<]*<\/span><\/a>)(?!\")"
        readonly property string selectHyperlink: `<a href=(?:(?!<a href=).)*?%1<\/span><\/a>`
        readonly property string hyperlinkFormat: `<a href="%1">%1</a>`
        readonly property string hoveredHyperlinkFormat: `<a href="%2" style="background-color: %1">%2</a>`.arg(Theme.palette.primaryColor3)

        active: root.enabled
        model: root.urlModel
        
        delegate: QtObject {
            id: hyperlinkDelegate
            // Model 
            required property string url

            // Helper properties
            readonly property string escapedURLforRegex: escapeRegExp(url)              // The url needs to be escaped to be used in regex
            readonly property string escapedUrlForReplacement: escapeReplacement(url)   // The url needs to be escaped to be used in the replacement string

            readonly property bool highlighted: url === root.highlightUrl
            
            // The hyperlink style can change when the preview is highlighted
            readonly property string hyperlinkToInsert: highlighted ? hyperlinksFormatter.hoveredHyperlinkFormat.arg(hyperlinkDelegate.escapedUrlForReplacement) :
                                                                    hyperlinksFormatter.hyperlinkFormat.arg(hyperlinkDelegate.escapedUrlForReplacement)

            // Behavior

            // Change the link style when anchoredHyperlink changes
            onHyperlinkToInsertChanged: replaceAll(hyperlinksFormatter.selectHyperlink.arg(hyperlinkDelegate.escapedURLforRegex), hyperlinkToInsert)
            // Handling text changes is needed to detect spaces inside hyperlink tags and move them outside of the tag
            // And to detect new duplicate links to add proper anchor tags
            property Connections textConnection: Connections {
                target: root.textEdit
                function onTextChanged() {
                    replaceAll("(<br/>|<br />| )+(</span></a>)", "$2$1") // Move spaces outside of the hyperlink tag
                    replaceAll(hyperlinksFormatter.selectLinkWithoutAnchors.arg(hyperlinkDelegate.escapedURLforRegex), hyperlinkDelegate.hyperlinkToInsert)
                }
            }
            // link detected -> add the hyperlink
            Component.onCompleted: replaceAll(hyperlinksFormatter.selectLinkWithoutAnchors.arg(hyperlinkDelegate.escapedURLforRegex), hyperlinkDelegate.hyperlinkToInsert)
            // link removed. Can happen when the link is removed or replaced in the input with another link
            Component.onDestruction: replaceAll(hyperlinksFormatter.selectLinkBetweenAnchors.arg(hyperlinkDelegate.escapedURLforRegex), "$1")

            // Helper functions
            function replaceAll(from, to) {
                const newText = root.textEdit.text.replace(new RegExp(from, 'g'), to)
                if(newText !== root.textEdit.text) {
                    textConnection.enabled = false
                    const cursorPosition = root.textEdit.cursorPosition
                    root.textEdit.text = newText
                    root.textEdit.cursorPosition = cursorPosition
                    textConnection.enabled = true
                }
            }

            function escapeRegExp(string) {
                let result = string.replace(/[.*+?^${}()|[\]\\/]/g, '\\$&'); // $& means the whole matched string
                result = result.replace(/&(?!amp;)/g, '&amp;')
                result = result.replace(/</g, '&lt;')
                result = result.replace(/>/g, '&gt;')
                result = result.replace(/\"/g, '&quot;')
                return decodeURI(result)
            }

            function escapeReplacement(string) {
                let result = decodeURI(string) // decode the url to be able to use it in the regex
                return result.replace(/\$/g, '$$$$');
            }
        }
    }
}
