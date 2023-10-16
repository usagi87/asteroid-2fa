/*
 * Copyright (C) 2016 Florent Revest <revestflo@gmail.com>
 *   2015 Tim Süberkrüb <tim.sueberkrueb@web.de>
 * Part of this code is based on "Stopwatch" (https://github.com/baleboy/stopwatch)
 * Copyright (C) 2011 Francesco Balestrieri
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import org.asteroid.controls 1.0
import org.asteroid.utils 1.0
import Nemo.Configuration 1.0
import TwoFactor 1.0
import Vault 1.0
import Crypt 1.0
import QRCode 1.0
import QZXing 3.3
import QtQuick.VirtualKeyboard 2.0
import QtQuick.VirtualKeyboard.Settings 2.15

Application {
	id: app
	
	centerColor: "#b01c7e"
	outerColor: "#420a2f"

	property int i: 0
 	property var db : ""
 	property var datasize : 0 
 	property var database:[]
 	property var s: 1-0.207
 	property string getText
 	property string getText2

	TwoFactor{
 		id:twofactor
 	}
 	Vault{
 		id:vault
 	}
 	
 	QRCode{
		id:qrcode
	}
 	Crypt{
 		id:crypt
 	}
			
	function readData() {
	   	var list = db.split(";")
	   	var len = list.length-1
	   	var x = 0;
		for (var j = 0; j < len; ++j) {
			var tmp = list[j].split(":");
			database.push({"issuer":tmp[0],
								"secret":tmp[1],
								"algo":tmp[2],
								"digit":parseInt(tmp[3]),
								"period":parseInt(tmp[4])});		
		}   	
		datasize = database.length
	}
 	
 	function addData(issuer, secret, algo, digit, period) {
 		if (issuer != "" && secret != ""){
			database.push({"issuer": issuer, 
								"secret": secret,
								"algo": algo,
								"digit": digit,
								"period":period}) 			
 			datasize = database.length
 		}
 	}
 	
	function removeData(itemId) {
 		if(itemId > -1)	{
 			database.splice(itemId,1);
 			datasize = database.length
 		}
 	}
 	
 	function saveData(){
 		db = "";
 		for (var j=0;j<datasize;++j){
			db += database[j].issuer + ":";
			db += database[j].secret + ":";
			db += database[j].algo + ":";
			db += database[j].digit + ":";
			db += database[j].period + ";";		
 		}
 	}
 	
 	LayerStack {
   	id: layerStack
		firstPage: passwordPage
	}
	
	Component {
		id:passwordPage
		Item{
		id:rootM
			TextBox {
			id: passwordField
			anchors.verticalCenter:parent.verticalCenter
    		anchors.horizontalCenter:parent.horizontalCenter
    		width: Dims.w(80)
			height: 50
			previewText: qsTrId("Password")
			inputMethodHints: Qt.ImhNumbersOnly | Qt.ImhUppercaseOnly
			text:getText
			MouseArea {
    			anchors.fill: parent
    			onClicked: {
    				getText = ""
                	layerStack.push(keyboardPage);
                }
			}
		}
       		
		IconButton {
			anchors.horizontalCenter: parent.horizontalCenter
        	anchors.bottom: parent.bottom
        	anchors.bottomMargin: Dims.h(15)
			iconName: "ios-checkmark-circle-outline"
			onClicked: { 
				
 				db = vault.readDatabase(passwordField.text)
				readData()
				getText = ""
				layerStack.push(issuerPage)
 			}
		}
	}
	}

	Component{	
		id:issuerPage
		Item {
	  		Spinner {
 				id: codeId
				height: parent.height
				width: parent.width
				model: datasize
				delegate: SpinnerDelegate { text:database[index].issuer}
			}

		IconButton {
			anchors.verticalCenter: parent.verticalCenter
			anchors.right : parent.right
			iconName: "ios-checkmark-circle-outline"
			onClicked: {
 				i = codeId.currentIndex 
				layerStack.push(codePage)
 			}
		}
		IconButton {
			anchors.verticalCenter: parent.verticalCenter
 			anchors.left : parent.left
 			iconName: "ios-folder-open"
 			onClicked: {
				layerStack.push(menuPage)
 			}
		}	
			
		}
	}
	
	Component{
		id:savePage
		Item{
			id:rootM
			TextBox {
				id: lockField
				anchors.horizontalCenter : parent.horizontalCenter
				anchors.verticalCenter : parent.verticalCenter
				width: Dims.w(80)
				height: Dims.h(15)
				echoMode:TextInput.Password
				inputMethodHints:Qt.ImhSensitiveData
				previewText: qsTrId("Password")
				text: getText
				MouseArea {
       				anchors.fill: parent
       				onClicked: { 
       					getText = ""
       					layerStack.push(keyboardPage) 
       				}
    			}
			}

			//HandWritingKeyboard {
			//	anchors.fill: parent
			//}
			
			IconButton {
 				anchors.bottom : parent.bottom
 				anchors.horizontalCenter : parent.horizontalCenter
 				anchors.bottomMargin: Dims.h(15)		
 				iconName: "ios-checkmark-circle-outline"
 				onClicked: {
 					saveData()
 					vault.saveDatabase(lockField.text,db,datasize)
 					getText = ""
					layerStack.pop(rootM)
 				}
			}
		}
	}
	
	Component {
		id:codePage
		Item {
			Label {
       			id: codeLabel
         		textFormat: Text.RichText
         		anchors.centerIn: parent
         		text: twofactor.getCode(database[i].secret).toString().padStart(database[i].digit, '0')
         		font.pixelSize: Dims.h(15) // originally 25
         		horizontalAlignment: Text.AlignHCenter
      		}
        
        
        Canvas {
           	id: display
           	anchors.fill: parent
           	smooth: true
           	renderStrategy: Canvas.Threaded
			onPaint: {
              	var ctx = getContext("2d")
              	ctx.reset()
              	ctx.shadowColor = (0, 0, 0, 0.25)
              	ctx.shadowOffsetX = 0
              	ctx.shadowOffsetY = 0
              	ctx.shadowBlur = parent.height*0.00625
              	ctx.lineCap="round"
              	ctx.beginPath()
              	var fraction_of_circle = (new Date().getSeconds() % 30) / 30
              	var start_angle = -0.5*Math.PI
              	var end_angle = start_angle + (2 * Math.PI * fraction_of_circle)
  			  	ctx.arc(parent.width/2, parent.height/2, width / 2.2, start_angle-0.01, end_angle+0.01, true);
              	ctx.lineWidth = parent.width * 0.01
              	ctx.strokeStyle = Qt.rgba(1,1,1,0.5)
              	ctx.stroke()
              	if (fraction_of_circle === 0) { // update the code
                   codeLabel.text = twofactor.getCode(database[i].secret).toString().padStart(database[i].digit, '0')
              	}
          	}
    	}
    
    	Timer {
        	interval: 500
        	running: true
        	repeat: true
        	triggeredOnStart: true
        	onTriggered: {
            display.requestPaint()
        	}
    	}
	}
	}

	Component{
		id:addPage
		Item {
			id:rootM 
			TextBox {
				id: secretField
				anchors.verticalCenter : parent.verticalCenter
				anchors.horizontalCenter : parent.horizontalCenter
				width: Dims.w(80)
				height: Dims.h(15)
				previewText: qsTrId("Shared secret")
				inputMethodHints:Qt.ImhNumbersOnly | Qt.ImhUppercaseOnly
				text:getText2
				MouseArea {
       				anchors.fill: parent
       				onClicked: { 
       					getText2 = ""
       					layerStack.push(keyboard2Page, {inputMethodHints:Qt.ImhNumbersOnly | Qt.ImhUppercaseOnly}) 
       				}
    			}
			}
			TextBox {
				id: issuerField
				anchors.horizontalCenter : parent.horizontalCenter
				anchors.bottom : secretField.top
				anchors.bottomMargin: 10
				width: Dims.w(80)
				height:Dims.h(15)
				previewText: qsTrId("Issuer name")
				inputMethodHints: Qt.ImhNumbersOnly | Qt.ImhUppercaseOnly
				text:getText
				MouseArea {
       				anchors.fill: parent
       				onClicked: { 
       					getText=""
       					layerStack.push(keyboardPage) 
       					
       				}
    			}
			}
			
			//HandWritingKeyboard {
			//	anchors.fill: parent
			//}
	
			IconButton {
 				anchors.bottom : parent.bottom
 				anchors.horizontalCenter : parent.horizontalCenter		
 				anchors.bottomMargin: Dims.h(15)
 				iconName: "ios-checkmark-circle-outline"
 				onClicked: {
 					addData(issuerField.text,secretField.text,"SHA1","6","30")
 					getText = ""
 					getText2 = ""
					layerStack.pop(rootM)
 				}
			}
  		}
	}
	
	Component {
		id:removePage	
		Item {
		id:rootM
		Spinner {
    		id: config
    		anchors.verticalCenter: parent.verticalCenter
         	anchors.horizontalCenter: parent.horizontalCenter
         	
			height: parent.height
    		width: parent.width
    		model: datasize
    		delegate: SpinnerDelegate { text:database[index].issuer}
		}
		IconButton {
         	anchors.verticalCenter: parent.verticalCenter
			anchors.right : parent.right
			iconName: "ios-remove-circle"
         	onClicked: {
         		removeData(config.currentIndex)
         		layerStack.pop(rootM)
         	}
		}
		}
	}		
	
	Component {
		id:qrcodePage	
		Item {
		id:rootM
		Rectangle {
			anchors.verticalCenter:parent.verticalCenter
        	anchors.horizontalCenter:parent.horizontalCenter
        	width: parent.width
        	height : parent.height
			color:"black"
			opacity:1.0
		}
		Image {
			id: qrcodeImage
			anchors.verticalCenter:parent.verticalCenter
        	anchors.horizontalCenter:parent.horizontalCenter
        	width: parent.width * 0.7
        	height : parent.height * 0.7 
            antialiasing: false
        	opacity: 1.0
        	mipmap:true
         	source: "file:/home/ceres/export.jpeg"
         	
        
        MouseArea {
        	anchors.fill:parent
        	onClicked: { 
        		layerStack.pop(rootM) }
    		}
        }
		
		}
	}
	
	Component {
		id:exportPage	
		Item {
		id:rootM
		IconButton {
         	anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			iconName: "ion-qr-code-outline"
         	onClicked: {
         		layerStack.push(qrcodePage)
         		
         	}
		}
		
		}
	}
	
	
	Component {
		id: menuPage
		Flickable {
            contentHeight: settingsColumn.implicitHeight
            contentWidth: width
            boundsBehavior: Flickable.DragOverBounds
            flickableDirection: Flickable.VerticalFlick

            Column {
                id: settingsColumn
                anchors.fill: parent

                Item { width: parent.width; height: Dims.h(10);visible: DeviceInfo.hasRoundScreen}

                ListItem {
                    title: qsTrId("Add")
                    iconName: "ios-add-circle"
                    onClicked: {
                    	getText = ""
                    	getText2 = ""
                    	layerStack.push(addPage)
                    }
                }
                ListItem {
                    title: qsTrId("Remove")
                    iconName: "ios-remove-circle"
                    onClicked: layerStack.push(removePage)
                }
                ListItem {
                    title: qsTrId("Save")
                    iconName: "ios-lock"
                    onClicked: {
                    	getText = ""
                    	layerStack.push(savePage)
                    }
                }
                ListItem {
                    title: qsTrId("Export")
                    iconName: "ion-qr-code-outline"
                    onClicked: {
                    	qrcode.generateQRCodeTest()
                    	layerStack.push(qrcodePage)
                    }
                }
                   				
				Item { width: parent.width; height: Dims.h(10);visible: DeviceInfo.hasRoundScreen}

            }
        }
        
	}

Component {
	id:keyboardPage	
	Item {
		id:rootM
		property alias inputMethodHints: txtField.inputMethodHints
		property var pop
					
		TextField {
    		id: txtField
    		anchors.top:parent.top
    		anchors.topMargin :40
    		anchors.horizontalCenter:parent.horizontalCenter
    	    width: Dims.w(80)
    	    previewText: qsTrId("")
   		}	
	
		InputPanel {
    		id: kbd
    	   	anchors {
   		    	verticalCenter: parent.verticalCenter
   		    	horizontalCenter: parent.horizontalCenter
   			}
   			width:parent.width * 0.90 //Dims.w(95)
    	   	visible: active
   		}
		IconButton {
			id:txtEnter
			anchors.bottom : parent.bottom
 			anchors.horizontalCenter : parent.horizontalCenter		
 			iconName: "ios-checkmark-circle-outline"
 			onClicked: {
				getText = txtField.text	
				layerStack.pop(rootM)				
			}
		}
		Component.onCompleted: {
		VirtualKeyboardSettings.styleName = "watch"
		
   		}
	}		
}
Component {
	id:keyboard2Page	
	Item {
		id:rootM
		property alias inputMethodHints: txtField.inputMethodHints
		property var pop
					
		TextField {
    		id: txtField
    		anchors.top:parent.top
    		anchors.topMargin :40
    		anchors.horizontalCenter:parent.horizontalCenter
    	    width: Dims.w(80)
    	    previewText: qsTrId("")
   		}	
	
		InputPanel {
    		id: kbd
    	   	anchors {
   		    	verticalCenter: parent.verticalCenter
   		    	horizontalCenter: parent.horizontalCenter
   			}
   			width:parent.width * 0.90 //Dims.w(95)
    	   	visible: active
   		}
		IconButton {
			id:txtEnter
			anchors.bottom : parent.bottom
 			anchors.horizontalCenter : parent.horizontalCenter		
 			iconName: "ios-checkmark-circle-outline"
 			onClicked: {
				getText2 = txtField.text	
				layerStack.pop(rootM)				
			}
		}
		Component.onCompleted: {
		VirtualKeyboardSettings.styleName = "watch"
		
   		}
	}		
}

}

