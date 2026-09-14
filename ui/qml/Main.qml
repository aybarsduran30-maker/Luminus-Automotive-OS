import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtMultimedia

Window {
    id: appWindow
    width: 1024
    height: 600
    minimumWidth: 840
    minimumHeight: 500
    visible: true
    title: "Luminus Automotive OS"
    color: "#000000"

    property int activeTab: 0
    property int themeColorIndex: 0
    property var themeColors: ["#C5A880", "#38BDF8", "#EF4444", "#10B981", "#A855F7"]
    readonly property color currentAccent: themeColors[themeColorIndex]

    property int layoutMode: 0
    property int bgMode: 2
    property string staticBgSource: ""
    property string liveVideoSource: Qt.resolvedUrl("../../assets/backgrounds/live_bg_1.mp4")
    property real bgDimOpacity: 0.55

    property int manualHour: 11
    property int manualMinute: 39
    property int manualYear: 2026
    property int manualMonth: 9
    property int manualDay: 14

    property real kerbWeight: 1090.0
    property real currentGrossWeight: 1170.0
    property real tireFL: 2.3
    property real tireFR: 2.3
    property real tireRL: 2.1
    property real tireRR: 1.8

    property bool tripActive: false
    property real liveTripDist: 0.0
    property real liveTripFuel: 0.0
    property var savedTripLogs: []

    property int statusBgIndex: 1
    property string statusMode: "TPMS"
    property bool statusRightSide: false

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Up) {
                vehicleSim.throttleActive = true
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                vehicleSim.brakeActive = true
                event.accepted = true
            }
        }

        Keys.onReleased: function(event) {
            if (event.key === Qt.Key_Up) {
                vehicleSim.throttleActive = false
                event.accepted = true
            } else if (event.key === Qt.Key_Down) {
                vehicleSim.brakeActive = false
                event.accepted = true
            }
        }
    }

    Timer {
        interval: 200
        running: tripActive && (vehicleSim.speed > 0.5)
        repeat: true
        onTriggered: {
            liveTripDist += (vehicleSim.speed * (0.2 / 3600.0))
            liveTripFuel += (0.0003 + (vehicleSim.throttleActive ? 0.0006 : 0.0001))
        }
    }

    Item {
        id: mediaLayer
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            visible: bgMode === 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#03060B" }
                GradientStop { position: 0.45; color: "#070E18" }
                GradientStop { position: 1.0; color: "#010204" }
            }
        }

        Image {
            anchors.fill: parent
            visible: bgMode === 1
            source: staticBgSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        Item {
            anchors.fill: parent
            visible: bgMode === 2

            MediaPlayer {
                id: livePlayer
                source: liveVideoSource
                loops: MediaPlayer.Infinite
                videoOutput: bgVideoOutput
                Component.onCompleted: {
                    livePlayer.play()
                }
            }

            VideoOutput {
                id: bgVideoOutput
                anchors.fill: parent
                fillMode: VideoOutput.PreserveAspectCrop
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: bgDimOpacity
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: currentAccent }
                GradientStop { position: 0.7; color: "transparent" }
            }
            opacity: 0.08
        }
    }

    Item {
        id: mainInterface
        anchors.fill: parent
        opacity: 0.0

        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

        Rectangle {
            id: topBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 44
            color: "#1A000000"
            border.color: "#18FFFFFF"
            border.width: 1
            z: 20

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Rectangle {
                    visible: activeTab !== 0
                    width: 74
                    height: 26
                    radius: 4
                    color: "#20FFFFFF"
                    border.color: currentAccent
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "< COCKPIT"
                        color: "#FFFFFF"
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            activeTab = 0
                        }
                    }
                }

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: currentAccent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "CITROEN C-ELYSEE  |  LUMINUS OS"
                    color: currentAccent
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 2
                }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                Text {
                    text: manualDay + "/" + (manualMonth < 10 ? "0" + manualMonth : manualMonth) + "/" + manualYear
                    color: "#64748B"
                    font.pixelSize: 10
                    font.bold: true
                }

                Text {
                    text: (manualHour < 10 ? "0" + manualHour : manualHour) + ":" + (manualMinute < 10 ? "0" + manualMinute : manualMinute)
                    color: "#FFFFFF"
                    font.pixelSize: 12
                    font.bold: true
                }
            }
        }

        Item {
            id: coreViewport
            anchors.top: topBar.bottom
            anchors.bottom: navigationDock.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14

            Item {
                visible: activeTab === 0
                anchors.fill: parent

                Item {
                    visible: layoutMode === 0
                    anchors.fill: parent

                    Row {
                        anchors.fill: parent
                        spacing: 16

                        Rectangle {
                            width: parent.width * 0.48
                            height: parent.height
                            radius: 16
                            color: "#0AFFFFFF"
                            border.color: "#18FFFFFF"
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 14

                                Text {
                                    text: "POWERTRAIN TELEMETRY"
                                    color: currentAccent
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.letterSpacing: 2
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                Row {
                                    spacing: 30
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Column {
                                        spacing: 4
                                        Text { text: "SPEED"; color: "#64748B"; font.pixelSize: 10; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: vehicleSim.speed.toFixed(0); color: "#FFFFFF"; font.pixelSize: 56; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: "KM/H"; color: currentAccent; font.pixelSize: 10; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                    }

                                    Rectangle { width: 1; height: 80; color: "#20FFFFFF"; anchors.verticalCenter: parent.verticalCenter }

                                    Column {
                                        spacing: 4
                                        Text { text: "ENGINE"; color: "#64748B"; font.pixelSize: 10; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: vehicleSim.rpm.toFixed(0); color: "#38BDF8"; font.pixelSize: 56; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: "RPM"; color: "#38BDF8"; font.pixelSize: 10; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                    }
                                }

                                Rectangle {
                                    width: 330
                                    height: 44
                                    radius: 8
                                    color: "#10FFFFFF"
                                    border.color: "#1EFFFFFF"

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 40
                                        Text { text: "COOLANT: " + vehicleSim.coolantTemp.toFixed(0) + " C"; color: vehicleSim.coolantTemp > 98 ? "#EF4444" : "#94A3B8"; font.pixelSize: 11; font.bold: true }
                                        Text { text: "BATTERY: " + vehicleSim.batteryVoltage.toFixed(1) + " V"; color: "#10B981"; font.pixelSize: 11; font.bold: true }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width * 0.52 - 16
                            height: parent.height
                            radius: 16
                            color: "#0AFFFFFF"
                            border.color: "#18FFFFFF"
                            border.width: 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 18
                                spacing: 14

                                Text { text: "DYNAMICS & QUICK LOGS"; color: currentAccent; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2 }

                                Rectangle {
                                    width: parent.width
                                    height: 74
                                    radius: 10
                                    color: "#12FFFFFF"
                                    border.color: "#1EFFFFFF"

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 36
                                        Column {
                                            Text { text: "0-100 KM/H TIMER"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                            Text { text: vehicleSim.dragTime.toFixed(2) + " s"; color: vehicleSim.isDragRunning ? "#38BDF8" : "#FFFFFF"; font.pixelSize: 24; font.bold: true }
                                        }
                                        Column {
                                            Text { text: "BEST RECORD"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                            Text { text: vehicleSim.bestDragTime > 0 ? vehicleSim.bestDragTime.toFixed(2) + " s" : "--.-- s"; color: "#10B981"; font.pixelSize: 24; font.bold: true }
                                        }
                                    }
                                }

                                Row {
                                    spacing: 12
                                    width: parent.width

                                    Rectangle {
                                        width: (parent.width - 12) / 2
                                        height: 80
                                        radius: 10
                                        color: "#12FFFFFF"
                                        border.color: tireRR < 2.0 ? "#EF4444" : "#1EFFFFFF"

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            Text { text: "CHASSIS MASS"; color: "#64748B"; font.pixelSize: 9; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                            Text { text: currentGrossWeight.toFixed(0) + " KG (GROSS)"; color: "#FFFFFF"; font.pixelSize: 13; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                        }
                                    }

                                    Rectangle {
                                        width: (parent.width - 12) / 2
                                        height: 80
                                        radius: 10
                                        color: "#12FFFFFF"
                                        border.color: "#1EFFFFFF"

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 4
                                            Text { text: "LIVE TRIP STATUS"; color: "#64748B"; font.pixelSize: 9; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                            Text { text: tripActive ? (liveTripDist.toFixed(1) + " KM REC") : "TRIP IDLE"; color: tripActive ? "#10B981" : "#94A3B8"; font.pixelSize: 13; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    visible: layoutMode === 1
                    anchors.fill: parent

                    Grid {
                        anchors.centerIn: parent
                        columns: 3
                        spacing: 16

                        readonly property real cW: (coreViewport.width - 48) / 3
                        readonly property real cH: (coreViewport.height - 32) / 2

                        component GridItemCard : Rectangle {
                            property string gTitle: ""
                            property string gSub: ""
                            property color gColor: currentAccent
                            property int gTab: 0

                            width: parent.cW
                            height: parent.cH
                            radius: 12
                            color: gMouse.containsMouse ? "#20FFFFFF" : "#0DFFFFFF"
                            border.color: gMouse.containsMouse ? gColor : "#1AFFFFFF"

                            Column {
                                anchors.centerIn: parent
                                spacing: 6
                                Text { text: gTitle; color: "#FFFFFF"; font.pixelSize: 13; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: gSub; color: gColor; font.pixelSize: 9; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                            }

                            MouseArea {
                                id: gMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    activeTab = gTab
                                }
                            }
                        }

                        GridItemCard { gTitle: "VEHICLE STATUS"; gSub: "CHASSIS & TPMS"; gColor: "#38BDF8"; gTab: 1 }
                        GridItemCard { gTitle: "PERFORMANCE"; gSub: "0-100 & DYNAMICS"; gColor: "#22C55E"; gTab: 2 }
                        GridItemCard { gTitle: "MEDIA"; gSub: "AUDIO & SINK"; gColor: "#F59E0B"; gTab: 3 }
                        GridItemCard { gTitle: "TRIP COMPUTER"; gSub: "LOGS & CONSUMPTION"; gColor: "#10B981"; gTab: 4 }
                        GridItemCard { gTitle: "SETTINGS"; gSub: "WALLPAPER & PREFS"; gColor: "#A855F7"; gTab: 5 }
                    }
                }
            }

            Item {
                visible: activeTab === 1
                anchors.fill: parent

                Item {
                    id: statusViewport
                    anchors.fill: parent

                    MediaPlayer {
                        id: statusBgPlayer
                        source: Qt.resolvedUrl("../../assets/backgrounds/live_bg_" + appWindow.statusBgIndex + ".mp4")
                        audioOutput: null
                        loops: MediaPlayer.Infinite
                        Component.onCompleted: {
                            statusBgPlayer.play()
                        }
                    }

                    VideoOutput {
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectCrop
                    }

                    Rectangle {
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#EE04060A" }
                            GradientStop { position: 0.5; color: "#C0080D14" }
                            GradientStop { position: 1.0; color: "#F6020406" }
                        }
                    }

                    Item {
                        id: stageArea
                        width: parent.width * 0.62
                        height: parent.height
                        anchors.left: parent.left

                        Rectangle {
                            id: groundRing
                            width: parent.width * 0.88
                            height: 64
                            radius: width / 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 60
                            color: "transparent"
                            border.color: currentAccent
                            border.width: 2
                            opacity: 0.28
                        }

                        Image {
                            id: vehicleRenderer
                            anchors.centerIn: stageArea
                            anchors.verticalCenterOffset: -20
                            width: parent.width * 0.85
                            fillMode: Image.PreserveAspectFit
                            source: {
                                if (appWindow.statusMode === "WEIGHT") {
                                    return "qrc:/assets/vehicles/car_upside.png"
                                }
                                if (appWindow.statusMode === "DIAGNOSTICS") {
                                    return "qrc:/assets/vehicles/car_side.png"
                                }
                                return appWindow.statusRightSide ? "qrc:/assets/vehicles/car_right.png" : "qrc:/assets/vehicles/car_left.png"
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 180 }
                            }
                        }

                        Item {
                            id: tpmsHudLayer
                            anchors.fill: vehicleRenderer
                            visible: appWindow.statusMode === "TPMS"

                            Rectangle {
                                x: appWindow.statusRightSide ? parent.width * 0.74 : parent.width * 0.12
                                y: parent.height * 0.60
                                width: 118
                                height: 46
                                color: "#B004070D"
                                border.color: (appWindow.statusRightSide ? tireFR : tireFL) < 2.0 ? "#EF4444" : "#00F0FF"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: appWindow.statusRightSide ? "FRONT RIGHT" : "FRONT LEFT"
                                        color: "#5C6E82"
                                        font.pixelSize: 8
                                        font.bold: true
                                    }
                                    Text {
                                        text: (appWindow.statusRightSide ? tireFR.toFixed(1) : tireFL.toFixed(1)) + " BAR | 24°C"
                                        color: (appWindow.statusRightSide ? tireFR : tireFL) < 2.0 ? "#EF4444" : "#00F0FF"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                }
                            }

                            Rectangle {
                                x: appWindow.statusRightSide ? parent.width * 0.12 : parent.width * 0.74
                                y: parent.height * 0.60
                                width: 118
                                height: 46
                                color: "#B004070D"
                                border.color: (appWindow.statusRightSide ? tireRR : tireRL) < 2.0 ? "#EF4444" : "#00F0FF"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: appWindow.statusRightSide ? "REAR RIGHT" : "REAR LEFT"
                                        color: "#5C6E82"
                                        font.pixelSize: 8
                                        font.bold: true
                                    }
                                    Text {
                                        text: (appWindow.statusRightSide ? tireRR.toFixed(1) : tireRL.toFixed(1)) + " BAR | 23°C"
                                        color: (appWindow.statusRightSide ? tireRR : tireRL) < 2.0 ? "#EF4444" : "#00F0FF"
                                        font.pixelSize: 12
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        Item {
                            id: weightHudLayer
                            anchors.fill: vehicleRenderer
                            visible: appWindow.statusMode === "WEIGHT"

                            Rectangle {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: 30
                                width: 160
                                height: 52
                                color: "#B00E0803"
                                border.color: "#FF9500"
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    Text {
                                        text: "TRUNK & AXLE LOAD"
                                        color: "#8E6948"
                                        font.pixelSize: 8
                                        font.bold: true
                                    }
                                    Text {
                                        text: (currentGrossWeight - kerbWeight).toFixed(0) + " KG / 506 L"
                                        color: "#FF9500"
                                        font.pixelSize: 13
                                        font.bold: true
                                    }
                                }
                            }
                        }
                    }

                    Column {
                        width: 300
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Rectangle {
                            width: parent.width
                            height: 64
                            color: appWindow.statusMode === "TPMS" ? "#2400F0FF" : "#8005080E"
                            border.color: appWindow.statusMode === "TPMS" ? "#00F0FF" : "#1A2536"
                            border.width: 1

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    appWindow.statusMode = "TPMS"
                                }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 2
                                Text {
                                    text: "TIRE MONITORING (TPMS)"
                                    color: "#FFFFFF"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: tireRR < 2.0 ? "WARNING: LOW PRESSURE DETECTED" : "ALL SENSORS OPTIMAL"
                                    color: tireRR < 2.0 ? "#EF4444" : "#00F0FF"
                                    font.pixelSize: 9
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 34
                            visible: appWindow.statusMode === "TPMS"
                            color: "#8005080E"
                            border.color: "#2C3E55"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: appWindow.statusRightSide ? "VIEW: RIGHT PROFILE (CLICK TO SWAP)" : "VIEW: LEFT PROFILE (CLICK TO SWAP)"
                                color: "#00F0FF"
                                font.pixelSize: 9
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    appWindow.statusRightSide = !appWindow.statusRightSide
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 64
                            color: appWindow.statusMode === "WEIGHT" ? "#24FF9500" : "#8005080E"
                            border.color: appWindow.statusMode === "WEIGHT" ? "#FF9500" : "#1A2536"
                            border.width: 1

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    appWindow.statusMode = "WEIGHT"
                                }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 2
                                Text {
                                    text: "CHASSIS LOAD DISTRIBUTION"
                                    color: "#FFFFFF"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: "GROSS: " + currentGrossWeight.toFixed(0) + " KG (KERB: " + kerbWeight.toFixed(0) + " KG)"
                                    color: "#FF9500"
                                    font.pixelSize: 9
                                }
                            }
                        }

                        Rectangle {
                            width: parent.width
                            height: 64
                            color: appWindow.statusMode === "DIAGNOSTICS" ? "#24FF003C" : "#8005080E"
                            border.color: appWindow.statusMode === "DIAGNOSTICS" ? "#FF003C" : "#1A2536"
                            border.width: 1

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    appWindow.statusMode = "DIAGNOSTICS"
                                }
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 2
                                Text {
                                    text: "VEHICLE DIAGNOSTICS"
                                    color: "#FFFFFF"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                                Text {
                                    text: "WIREFRAME TELEMETRY ACTIVE"
                                    color: "#FF003C"
                                    font.pixelSize: 9
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 32
                                color: "#8005080E"
                                border.color: "#1A2536"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "PREV BG"
                                    color: "#8CA0B8"
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (appWindow.statusBgIndex > 1) {
                                            appWindow.statusBgIndex = appWindow.statusBgIndex - 1
                                        } else {
                                            appWindow.statusBgIndex = 8
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 32
                                color: "#8005080E"
                                border.color: "#1A2536"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "NEXT BG (" + appWindow.statusBgIndex + "/8)"
                                    color: "#8CA0B8"
                                    font.pixelSize: 9
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (appWindow.statusBgIndex < 8) {
                                            appWindow.statusBgIndex = appWindow.statusBgIndex + 1
                                        } else {
                                            appWindow.statusBgIndex = 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                visible: activeTab === 2
                anchors.fill: parent

                Row {
                    anchors.fill: parent
                    spacing: 16

                    Rectangle {
                        width: parent.width * 0.55
                        height: parent.height
                        radius: 16
                        color: "#0AFFFFFF"
                        border.color: "#18FFFFFF"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 14

                            Text { text: "ACCELERATION ANALYZER"; color: currentAccent; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2; anchors.horizontalCenter: parent.horizontalCenter }

                            Text {
                                text: vehicleSim.dragTime.toFixed(2) + " s"
                                color: vehicleSim.isDragRunning ? "#38BDF8" : "#FFFFFF"
                                font.pixelSize: 52
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "BEST RECORD: " + (vehicleSim.bestDragTime > 0 ? vehicleSim.bestDragTime.toFixed(2) + " s" : "--.-- s")
                                color: "#10B981"
                                font.pixelSize: 13
                                font.bold: true
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Rectangle {
                                width: 160
                                height: 40
                                radius: 6
                                color: "#25FFFFFF"
                                border.color: currentAccent
                                border.width: 1
                                anchors.horizontalCenter: parent.horizontalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "RESET / ARM TIMER"
                                    color: "#FFFFFF"
                                    font.pixelSize: 11
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        vehicleSim.resetDragTimer()
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width * 0.45 - 16
                        height: parent.height
                        radius: 16
                        color: "#0AFFFFFF"
                        border.color: "#18FFFFFF"
                        border.width: 1

                        Column {
                            anchors.centerIn: parent
                            spacing: 18

                            Text { text: "DYNAMIC POWER GAUGE"; color: currentAccent; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2; anchors.horizontalCenter: parent.horizontalCenter }

                            Column {
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                Text { text: "CURRENT VELOCITY"; color: "#64748B"; font.pixelSize: 10; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: vehicleSim.speed.toFixed(0) + " KM/H"; color: "#FFFFFF"; font.pixelSize: 28; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                            }

                            Column {
                                spacing: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                Text { text: "TACHOMETER"; color: "#64748B"; font.pixelSize: 10; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: vehicleSim.rpm.toFixed(0) + " RPM"; color: "#38BDF8"; font.pixelSize: 28; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }
                }
            }

            Item {
                visible: activeTab === 3
                anchors.fill: parent

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(500, parent.width * 0.8)
                    height: Math.min(260, parent.height * 0.7)
                    radius: 16
                    color: "#0AFFFFFF"
                    border.color: "#18FFFFFF"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 16
                        Text { text: "AUDIO SOURCE"; color: currentAccent; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "NO DEVICE CONNECTED"; color: "#FFFFFF"; font.pixelSize: 18; font.bold: true; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Ready for Bluetooth Sink Broadcast"; color: "#64748B"; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
            }

            Item {
                visible: activeTab === 4
                anchors.fill: parent

                Row {
                    anchors.fill: parent
                    spacing: 16

                    Rectangle {
                        width: parent.width * 0.58
                        height: parent.height
                        radius: 16
                        color: "#0AFFFFFF"
                        border.color: "#18FFFFFF"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 16

                            Text { text: "CURRENT TRIP METRICS"; color: currentAccent; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2 }

                            Grid {
                                columns: 2
                                spacing: 12

                                Rectangle {
                                    width: 190
                                    height: 60
                                    radius: 8
                                    color: "#12FFFFFF"
                                    Column {
                                        anchors.centerIn: parent
                                        Text { text: "LIVE DISTANCE"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                        Text { text: liveTripDist.toFixed(2) + " KM"; color: "#FFFFFF"; font.pixelSize: 15; font.bold: true }
                                    }
                                }

                                Rectangle {
                                    width: 190
                                    height: 60
                                    radius: 8
                                    color: "#12FFFFFF"
                                    Column {
                                        anchors.centerIn: parent
                                        Text { text: "AVG CONSUMPTION"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                        Text {
                                            text: liveTripDist > 0 ? ((liveTripFuel / liveTripDist) * 100).toFixed(1) + " L/100KM" : "0.0 L/100KM"
                                            color: "#10B981"
                                            font.pixelSize: 15
                                            font.bold: true
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: 12
                                Rectangle {
                                    width: 110
                                    height: 38
                                    radius: 6
                                    color: tripActive ? "#25EF4444" : "#2510B981"
                                    border.color: tripActive ? "#EF4444" : "#10B981"
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: tripActive ? "STOP TRIP" : "NEW TRIP"; color: "#FFFFFF"; font.pixelSize: 10; font.bold: true }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (!tripActive) {
                                                liveTripDist = 0.0
                                                liveTripFuel = 0.0
                                                tripActive = true
                                            } else {
                                                tripActive = false
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 110
                                    height: 38
                                    radius: 6
                                    color: "#20FFFFFF"
                                    border.color: currentAccent
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: "SAVE TRIP"; color: "#FFFFFF"; font.pixelSize: 10; font.bold: true }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (liveTripDist > 0.0) {
                                                var copy = savedTripLogs.slice()
                                                var avgCons = ((liveTripFuel / liveTripDist) * 100).toFixed(1)
                                                copy.push(liveTripDist.toFixed(1) + " KM @ " + avgCons + " L/100KM")
                                                savedTripLogs = copy
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 110
                                    height: 38
                                    radius: 6
                                    color: "#15FFFFFF"
                                    border.color: "#30FFFFFF"
                                    border.width: 1
                                    Text { anchors.centerIn: parent; text: "RESET"; color: "#FFFFFF"; font.pixelSize: 10; font.bold: true }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            tripActive = false
                                            liveTripDist = 0.0
                                            liveTripFuel = 0.0
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width * 0.42 - 16
                        height: parent.height
                        radius: 16
                        color: "#0AFFFFFF"
                        border.color: "#18FFFFFF"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 10

                            Text { text: "SAVED TRIPS LOG"; color: currentAccent; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2 }

                            ListView {
                                width: parent.width
                                height: parent.height - 40
                                clip: true
                                model: savedTripLogs
                                spacing: 6
                                delegate: Rectangle {
                                    width: parent.width
                                    height: 32
                                    radius: 6
                                    color: "#14FFFFFF"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Log #" + (index + 1) + ": " + modelData
                                        color: "#FFFFFF"
                                        font.pixelSize: 10
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                visible: activeTab === 5
                anchors.fill: parent

                Row {
                    anchors.centerIn: parent
                    spacing: 20

                    Rectangle {
                        width: 380
                        height: 320
                        radius: 16
                        color: "#0AFFFFFF"
                        border.color: "#18FFFFFF"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 16

                            Text { text: "WALLPAPER & MEDIA ENGINE"; color: currentAccent; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2 }

                            Column {
                                spacing: 6
                                Text { text: "BACKGROUND RENDER MODE"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                Row {
                                    spacing: 8
                                    Rectangle {
                                        width: 80
                                        height: 30
                                        radius: 6
                                        color: bgMode === 0 ? "#30FFFFFF" : "#12FFFFFF"
                                        border.color: bgMode === 0 ? currentAccent : "transparent"
                                        Text { anchors.centerIn: parent; text: "GRADIENT"; color: "#FFFFFF"; font.pixelSize: 9; font.bold: true }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                bgMode = 0
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: 80
                                        height: 30
                                        radius: 6
                                        color: bgMode === 1 ? "#30FFFFFF" : "#12FFFFFF"
                                        border.color: bgMode === 1 ? currentAccent : "transparent"
                                        Text { anchors.centerIn: parent; text: "STATIC 4K"; color: "#FFFFFF"; font.pixelSize: 9; font.bold: true }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                bgMode = 1
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: 80
                                        height: 30
                                        radius: 6
                                        color: bgMode === 2 ? "#30FFFFFF" : "#12FFFFFF"
                                        border.color: bgMode === 2 ? currentAccent : "transparent"
                                        Text { anchors.centerIn: parent; text: "LIVE MP4"; color: "#FFFFFF"; font.pixelSize: 9; font.bold: true }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                bgMode = 2
                                                livePlayer.play()
                                            }
                                        }
                                    }
                                }
                            }

                            Column {
                                spacing: 6
                                Text { text: "BACKGROUND DIM OPACITY (" + (bgDimOpacity * 100).toFixed(0) + "%)"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                Row {
                                    spacing: 8
                                    Rectangle {
                                        width: 30
                                        height: 28
                                        radius: 4
                                        color: "#20FFFFFF"
                                        Text { anchors.centerIn: parent; text: "-"; color: "#FFFFFF" }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                bgDimOpacity = Math.max(0.1, bgDimOpacity - 0.1)
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: 30
                                        height: 28
                                        radius: 4
                                        color: "#20FFFFFF"
                                        Text { anchors.centerIn: parent; text: "+"; color: "#FFFFFF" }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                bgDimOpacity = Math.min(0.9, bgDimOpacity + 0.1)
                                            }
                                        }
                                    }
                                }
                            }

                            Column {
                                spacing: 6
                                Text { text: "ACCENT PALETTE"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                Row {
                                    spacing: 10
                                    Repeater {
                                        model: themeColors
                                        Rectangle {
                                            width: 26
                                            height: 26
                                            radius: 13
                                            color: modelData
                                            border.color: themeColorIndex === index ? "#FFFFFF" : "transparent"
                                            border.width: 2
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    themeColorIndex = index
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: 380
                        height: 320
                        radius: 16
                        color: "#0AFFFFFF"
                        border.color: "#18FFFFFF"
                        border.width: 1

                        Column {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 16

                            Text { text: "LAYOUT & TIME CALIBRATION"; color: currentAccent; font.pixelSize: 11; font.bold: true; font.letterSpacing: 2 }

                            Column {
                                spacing: 6
                                Text { text: "HOME LAYOUT VIEW"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                Row {
                                    spacing: 8
                                    Rectangle {
                                        width: 110
                                        height: 30
                                        radius: 6
                                        color: layoutMode === 0 ? "#30FFFFFF" : "#12FFFFFF"
                                        border.color: layoutMode === 0 ? currentAccent : "transparent"
                                        Text { anchors.centerIn: parent; text: "COCKPIT"; color: "#FFFFFF"; font.pixelSize: 9; font.bold: true }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                layoutMode = 0
                                            }
                                        }
                                    }
                                    Rectangle {
                                        width: 110
                                        height: 30
                                        radius: 6
                                        color: layoutMode === 1 ? "#30FFFFFF" : "#12FFFFFF"
                                        border.color: layoutMode === 1 ? currentAccent : "transparent"
                                        Text { anchors.centerIn: parent; text: "FULL GRID"; color: "#FFFFFF"; font.pixelSize: 9; font.bold: true }
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                layoutMode = 1
                                            }
                                        }
                                    }
                                }
                            }

                            Row {
                                spacing: 20
                                Column {
                                    spacing: 4
                                    Text { text: "HOUR"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                    Row {
                                        spacing: 6
                                        Rectangle {
                                            width: 28
                                            height: 28
                                            radius: 4
                                            color: "#20FFFFFF"
                                            Text { anchors.centerIn: parent; text: "-"; color: "#FFFFFF" }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (manualHour > 0) {
                                                        manualHour = manualHour - 1
                                                    } else {
                                                        manualHour = 23
                                                    }
                                                }
                                            }
                                        }
                                        Text { text: (manualHour < 10 ? "0" + manualHour : manualHour); color: "#FFFFFF"; font.pixelSize: 15; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                                        Rectangle {
                                            width: 28
                                            height: 28
                                            radius: 4
                                            color: "#20FFFFFF"
                                            Text { anchors.centerIn: parent; text: "+"; color: "#FFFFFF" }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (manualHour < 23) {
                                                        manualHour = manualHour + 1
                                                    } else {
                                                        manualHour = 0
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Column {
                                    spacing: 4
                                    Text { text: "MINUTE"; color: "#64748B"; font.pixelSize: 9; font.bold: true }
                                    Row {
                                        spacing: 6
                                        Rectangle {
                                            width: 28
                                            height: 28
                                            radius: 4
                                            color: "#20FFFFFF"
                                            Text { anchors.centerIn: parent; text: "-"; color: "#FFFFFF" }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (manualMinute > 0) {
                                                        manualMinute = manualMinute - 1
                                                    } else {
                                                        manualMinute = 59
                                                    }
                                                }
                                            }
                                        }
                                        Text { text: (manualMinute < 10 ? "0" + manualMinute : manualMinute); color: "#FFFFFF"; font.pixelSize: 15; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                                        Rectangle {
                                            width: 28
                                            height: 28
                                            radius: 4
                                            color: "#20FFFFFF"
                                            Text { anchors.centerIn: parent; text: "+"; color: "#FFFFFF" }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    if (manualMinute < 59) {
                                                        manualMinute = manualMinute + 1
                                                    } else {
                                                        manualMinute = 0
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: navigationDock
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 52
            color: "#16000000"
            border.color: "#18FFFFFF"
            border.width: 1
            z: 20

            Row {
                anchors.centerIn: parent
                spacing: 12

                component DockButton : Rectangle {
                    property string dTitle: ""
                    property int dIndex: 0

                    width: 120
                    height: 34
                    radius: 6
                    color: activeTab === dIndex ? "#30FFFFFF" : (dockM.containsMouse ? "#18FFFFFF" : "#0AFFFFFF")
                    border.color: activeTab === dIndex ? currentAccent : "#18FFFFFF"
                    border.width: activeTab === dIndex ? 1.5 : 1

                    Text {
                        anchors.centerIn: parent
                        text: dTitle
                        color: activeTab === dIndex ? currentAccent : "#94A3B8"
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        id: dockM
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            activeTab = dIndex
                        }
                    }
                }

                DockButton { dTitle: "COCKPIT"; dIndex: 0 }
                DockButton { dTitle: "STATUS"; dIndex: 1 }
                DockButton { dTitle: "DYNAMICS"; dIndex: 2 }
                DockButton { dTitle: "MEDIA"; dIndex: 3 }
                DockButton { dTitle: "TRIP"; dIndex: 4 }
                DockButton { dTitle: "SETTINGS"; dIndex: 5 }
            }
        }
    }

    Rectangle {
        id: bootSplash
        anchors.fill: parent
        color: "#000000"
        z: 999
        visible: opacity > 0.0

        Behavior on opacity {
            NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
        }

        Column {
            anchors.centerIn: parent
            spacing: 20

            Image {
                id: bootLogo
                source: "qrc:/citroen_logo.png"
                width: 220
                height: 170
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.0
                scale: 0.85
            }

            Item {
                id: textContainer
                width: 320
                height: 30
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.0

                Text {
                    anchors.centerIn: parent
                    text: "LUMINUS AUTOMOTIVE OS"
                    color: currentAccent
                    font.pixelSize: 12
                    font.letterSpacing: 6
                    font.bold: true
                }
            }
        }

        SequentialAnimation {
            id: cinematicIntro
            running: true

            PauseAnimation { duration: 200 }

            ParallelAnimation {
                NumberAnimation { target: bootLogo; property: "opacity"; to: 1.0; duration: 800; easing.type: Easing.OutQuad }
                NumberAnimation { target: bootLogo; property: "scale"; to: 1.0; duration: 1000; easing.type: Easing.OutBack }
            }

            ParallelAnimation {
                NumberAnimation { target: textContainer; property: "opacity"; to: 1.0; duration: 500 }
            }

            PauseAnimation { duration: 1200 }

            ParallelAnimation {
                NumberAnimation { target: bootLogo; property: "opacity"; to: 0.0; duration: 400; easing.type: Easing.InQuad }
                NumberAnimation { target: textContainer; property: "opacity"; to: 0.0; duration: 300 }
            }

            ScriptAction {
                script: {
                    bootSplash.opacity = 0.0
                    mainInterface.opacity = 1.0
                }
            }
        }
    }
}
