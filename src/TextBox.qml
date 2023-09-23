import QtQuick 2.9
import org.asteroid.controls 1.0
import QtQuick.VirtualKeyboard 2.1

TextBase {
	id: textBox

   property alias color: textInput.color
   property alias text: textInput.text
   property alias textWidth: textInput.width
   property alias readOnly: textInput.readOnly
   property alias inputMethodHints: textInput.inputMethodHints
   property alias validator: textInput.validator
   property alias echoMode: textInput.echoMode
   property int passwordMaskDelay: 1000

   editor: textInput
 	
 	Flickable {
   	id: flickable

       x: 12
       clip: true
       width: parent.width
       height: parent.height
       flickableDirection: Flickable.HorizontalFlick
       interactive: contentWidth - 4 > width

       contentWidth: textInput.width - 2 
       contentHeight: textInput.height
       
       TextInput {
       	id: textInput

			EnterKeyAction.actionId: textBox.enterKeyAction
         EnterKeyAction.label: textBox.enterKeyText
         EnterKeyAction.enabled: textBox.enterKeyEnabled
			
			y: 6
         focus: true
         color: "#2B2C2E"
         cursorVisible: activeFocus
         passwordCharacter: "\u2022"
         font.pixelSize: textBox.fontPixelSize
         wrapMode: TextInput.WordWrap
         autoScroll:true
         width: flickable.width - 5
         height: flickable.height

         Binding {
         	target: textInput
            property: "passwordMaskDelay"
            value: textBox.passwordMaskDelay
            when: textInput.hasOwnProperty("passwordMaskDelay")
			}
		}
	}
}
