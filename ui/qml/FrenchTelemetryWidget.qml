import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 300
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    signal expandRequested()

    Rectangle {
        anchors.fill: parent
        anchors.margins: 12
        radius: 20
        color: "#0C1017"
        border.color: "#1E2638"
        border.width: 1

        Rectangle {
            anchors.fill: parent
            radius: 20
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#141B26" }
                GradientStop { position: 0.5; color: "#0A0D14" }
                GradientStop { position: 1.0; color: "#06080C" }
            }
        }

        Item {
            id: headerArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 50
            anchors.margins: 14

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    text: "CITROËN"
                    color: "#E2D9C8"
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 3
                }

                Text {
                    text: "C-ELYSÉE"
                    color: "#C5A880"
                    font.pixelSize: 11
                    font.letterSpacing: 2
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 64
                height: 26
                radius: 6
                color: "#141A24"
                border.color: "#C5A880"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "EXPAND"
                    color: "#E2D9C8"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expandRequested()
                }
            }
        }

        Rectangle {
            id: silhouetteContainer
            anchors.top: headerArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 190
            anchors.margins: 14
            radius: 14
            color: "#070A0F"
            border.color: "#161E2E"
            border.width: 1

            Rectangle {
                anchors.centerIn: parent
                width: 120
                height: 120
                radius: 60
                color: "transparent"
                border.color: "#162032"
                border.width: 1
            }

            Rectangle {
                anchors.centerIn: parent
                width: 90
                height: 90
                radius: 45
                color: "transparent"
                border.color: "#1F2D47"
                border.width: 1
            }

            Column {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "SEDAN CHASSIS"
                    color: "#475569"
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "1090 KG"
                    color: "#38BDF8"
                    font.pixelSize: 15
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "KERB WEIGHT"
                    color: "#64748B"
                    font.pixelSize: 8
                    font.letterSpacing: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Column {
            anchors.top: silhouetteContainer.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 14
            spacing: 14

            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 64
                    radius: 10
                    color: "#080B10"
                    border.color: "#182030"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "COOLANT"; color: "#64748B"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                        Text { 
                            text: vehicleSim.coolantTemp.toFixed(0) + " °C"
                            color: vehicleSim.coolantTemp > 100.0 ? "#EF4444" : "#E2D9C8"
                            font.pixelSize: 16
                            font.bold: true 
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 64
                    radius: 10
                    color: "#080B10"
                    border.color: "#182030"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "VOLTAGE"; color: "#64748B"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                        Text { 
                            text: vehicleSim.batteryVoltage.toFixed(1) + " V"
                            color: "#38BDF8"
                            font.pixelSize: 16
                            font.bold: true 
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 64
                    radius: 10
                    color: "#080B10"
                    border.color: "#182030"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "SPEED"; color: "#64748B"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                        Text { 
                            text: vehicleSim.speed.toFixed(0) + " KM/H"
                            color: "#FFFFFF"
                            font.pixelSize: 16
                            font.bold: true 
                        }
                    }
                }

                Rectangle {
                    width: (parent.width - 12) / 2
                    height: 64
                    radius: 10
                    color: "#080B10"
                    border.color: "#182030"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "ENGINE RPM"; color: "#64748B"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                        Text { 
                            text: vehicleSim.rpm.toFixed(0)
                            color: "#C5A880"
                            font.pixelSize: 16
                            font.bold: true 
                        }
                    }
                }
            }
        }
    }
}
