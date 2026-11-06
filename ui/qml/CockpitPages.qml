pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: root

    property int activeTab: 0
    property int themeColorIndex: 0
    property bool english: false
    property var themeColors: ["#C79A63", "#A7B4A8", "#B95150", "#D7D5CB"]
    property color accent: themeColors[themeColorIndex]
    property real speed: 0
    property real rpm: 850
    property real coolant: 85
    property real voltage: 13.9
    property real throttle: 0
    property real tireFL: 2.3
    property real tireFR: 2.3
    property real tireRL: 2.1
    property real tireRR: 2.1
    property real kerbWeight: 1090
    property real grossWeight: 1170
    property real dragTime: 0
    property real bestDragTime: 0
    property bool dragArmed: true
    property bool hardwareConnected: false
    property string rawPacket: ""
    property var vehicleSim
    property var appWindow

    readonly property color ink: "#F3F1EA"
    readonly property color muted: "#858B89"
    readonly property color panel: Qt.rgba(0.12, 0.14, 0.15, 0.60)
    readonly property color panelRaised: Qt.rgba(0.18, 0.20, 0.20, 0.56)
    readonly property color stroke: Qt.rgba(0.84, 0.87, 0.85, 0.20)

    function tr(turkish, englishText) {
        return root.english ? englishText : turkish
    }

    Item {
        anchors.fill: parent

        Rectangle {
            x: -170; y: parent.height * 0.24; width: 390; height: 390; radius: 195
            color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.075)
        }
        Rectangle {
            x: parent.width * 0.74; y: -190; width: 410; height: 410; radius: 205
            color: Qt.rgba(0.55, 0.63, 0.67, 0.06)
        }

        Item {
            visible: root.activeTab === 0
            anchors.fill: parent
            Row {
                anchors.fill: parent; spacing: 16
                Rectangle {
                    width: parent.width * 0.64; height: parent.height; radius: 24; color: root.panel; border.color: root.stroke
                    Column {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 26; spacing: 8
                        Text { text: root.tr("LUMINUS MULTİMEDYA", "LUMINUS MULTIMEDIA"); color: root.accent; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.5 }
                        Text { text: root.tr("Merhaba", "Good evening"); color: root.ink; font.pixelSize: 30; font.weight: Font.Light }
                        Text { text: "Citroën C-Elysée  ·  2013"; color: root.muted; font.pixelSize: 11 }
                    }
                    Column {
                        anchors.centerIn: parent; anchors.verticalCenterOffset: -4; spacing: 12
                        Rectangle {
                            width: 76; height: 76; radius: 38; color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.13)
                            border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.38); anchors.horizontalCenter: parent.horizontalCenter
                            Text { anchors.centerIn: parent; text: "♫"; color: root.accent; font.pixelSize: 34 }
                        }
                        Text { text: root.tr("Ses kaynağını bağla", "Connect an audio source"); color: root.ink; font.pixelSize: 19; font.weight: Font.Light; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: root.tr("Bağlandığında müzik ve oynatma kontrolleri burada görünür.", "Your music and playback controls will appear here when connected."); color: root.muted; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter }
                        Rectangle {
                            width: 142; height: 38; radius: 12; color: root.panelRaised; border.color: root.stroke; anchors.horizontalCenter: parent.horizontalCenter
                            Text { anchors.centerIn: parent; text: root.tr("MEDYAYI AÇ", "OPEN MEDIA"); color: root.ink; font.pixelSize: 9; font.bold: true; font.letterSpacing: 0.5 }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.appWindow.activeTab = 3 }
                        }
                    }
                    Row {
                        anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 20; spacing: 10
                        Rectangle {
                            width: 150; height: 48; radius: 14; color: Qt.rgba(1, 1, 1, 0.035); border.color: root.stroke
                            Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 14; text: root.tr("Araç durumu  ›", "Vehicle status  ›"); color: root.ink; font.pixelSize: 10; font.bold: true }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.appWindow.activeTab = 1 }
                        }
                        Rectangle {
                            width: 150; height: 48; radius: 14; color: Qt.rgba(1, 1, 1, 0.035); border.color: root.stroke
                            Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 14; text: root.tr("Yolculuk  ›", "Trip computer  ›"); color: root.ink; font.pixelSize: 10; font.bold: true }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.appWindow.activeTab = 4 }
                        }
                    }
                }
                Column {
                    width: parent.width * 0.34; height: parent.height; spacing: 12
                    Rectangle {
                        width: parent.width; height: (parent.height - 12) * 0.57; radius: 20; color: root.panel; border.color: root.stroke
                        Text { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 18; text: root.tr("ARAÇ", "VEHICLE"); color: root.muted; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.2 }
                        Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 18; anchors.bottomMargin: 43; text: Math.round(root.speed).toString(); color: root.ink; font.pixelSize: 54; font.weight: Font.Light; font.family: "Segoe UI Light" }
                        Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 20; anchors.bottomMargin: 23; text: "KM/H   ·   " + (root.hardwareConnected ? root.tr("OBD BAĞLI", "OBD CONNECTED") : root.tr("SİMÜLASYON", "SIMULATION")); color: root.accent; font.pixelSize: 8; font.bold: true; font.letterSpacing: 0.5 }
                        Rectangle { anchors.right: parent.right; anchors.top: parent.top; anchors.rightMargin: 18; anchors.topMargin: 18; width: 8; height: 8; radius: 4; color: root.hardwareConnected ? "#A7B4A8" : root.accent }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.appWindow.activeTab = 1 }
                    }
                    Rectangle {
                        width: parent.width; height: (parent.height - 12) * 0.43; radius: 20; color: root.panel; border.color: root.stroke
                        Text { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 18; text: root.tr("YOLCULUK", "TRIP"); color: root.muted; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1.2 }
                        Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 18; anchors.bottomMargin: 16; text: Number(root.appWindow.liveTripDist).toFixed(1) + " km"; color: root.ink; font.pixelSize: 24; font.weight: Font.Light }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.appWindow.activeTab = 4 }
                    }
                }
            }
        }
        Item {
            visible: root.activeTab === 1
            anchors.fill: parent
            Row {
                anchors.fill: parent; spacing: 16
                Rectangle {
                    width: parent.width * 0.45; height: parent.height; radius: 22; color: root.panel; border.color: root.stroke
                    Column {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 20; spacing: 5
                        Text { text: root.tr("ARAÇ DURUMU", "VEHICLE STATUS"); color: root.ink; font.pixelSize: 13; font.bold: true }
                        Text { text: root.tr("C-Elysée · şematik görünüm", "C-Elysée · schematic view"); color: root.muted; font.pixelSize: 10 }
                    }
                    Item {
                        width: 182; height: 286; anchors.centerIn: parent; anchors.verticalCenterOffset: 12
                        Rectangle { x: 18; y: 48; width: 22; height: 70; radius: 8; color: "#090B0C"; border.color: "#34393A" }
                        Rectangle { x: 142; y: 48; width: 22; height: 70; radius: 8; color: "#090B0C"; border.color: "#34393A" }
                        Rectangle { x: 18; y: 168; width: 22; height: 70; radius: 8; color: "#090B0C"; border.color: "#34393A" }
                        Rectangle { x: 142; y: 168; width: 22; height: 70; radius: 8; color: "#090B0C"; border.color: "#34393A" }
                        Rectangle { x: 43; y: 8; width: 96; height: 270; radius: 38; color: "#C9C7BE"; border.color: "#E2DFD5" }
                        Rectangle { x: 52; y: 28; width: 78; height: 62; radius: 22; color: "#353B3D"; border.color: "#7A7F7D" }
                        Rectangle { x: 52; y: 99; width: 78; height: 88; radius: 14; color: "#24292B"; border.color: "#8B8E88" }
                        Rectangle { x: 52; y: 196; width: 78; height: 56; radius: 18; color: "#343A3B"; border.color: "#7A7F7D" }
                        Rectangle { x: 48; y: 14; width: 18; height: 5; radius: 2; color: "#F0E8D8" }
                        Rectangle { x: 116; y: 14; width: 18; height: 5; radius: 2; color: "#F0E8D8" }
                        Rectangle { x: 48; y: 267; width: 18; height: 5; radius: 2; color: "#B95150" }
                        Rectangle { x: 116; y: 267; width: 18; height: 5; radius: 2; color: "#B95150" }
                        Rectangle { x: 88; y: 112; width: 6; height: 62; radius: 3; color: "#646A68"; opacity: 0.7 }
                    }
                }
                Column {
                    width: parent.width * 0.53; height: parent.height; spacing: 12
                    Row {
                        width: parent.width; height: 42; spacing: 8
                        Repeater {
                            model: [root.tr("LASTİK", "TYRES"), root.tr("YÜK", "LOAD"), root.tr("MOTOR", "ENGINE")]
                            Rectangle {
                                required property int index
                                required property var modelData
                                width: (parent.width - 16) / 3; height: parent.height; radius: 12
                                color: root.appWindow.statusMode === ["TPMS", "WEIGHT", "DIAGNOSTICS"][index] ? "#282723" : root.panel
                                border.color: root.appWindow.statusMode === ["TPMS", "WEIGHT", "DIAGNOSTICS"][index] ? root.accent : root.stroke
                                Text { anchors.centerIn: parent; text: modelData; color: root.appWindow.statusMode === ["TPMS", "WEIGHT", "DIAGNOSTICS"][index] ? root.accent : "#929795"; font.pixelSize: 10; font.bold: true }
                                MouseArea { anchors.fill: parent; onClicked: root.appWindow.statusMode = ["TPMS", "WEIGHT", "DIAGNOSTICS"][index] }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width; height: parent.height - 54; radius: 22; color: root.panel; border.color: root.stroke
                        Column {
                            anchors.fill: parent; anchors.margins: 20; spacing: 9
                            Text { text: root.appWindow.statusMode === "TPMS" ? root.tr("LASTİK BASINÇLARI", "TYRE PRESSURES") : root.appWindow.statusMode === "WEIGHT" ? root.tr("ARAÇ YÜKÜ", "VEHICLE LOAD") : root.tr("MOTOR VERİLERİ", "ENGINE DATA"); color: root.ink; font.pixelSize: 12; font.bold: true }
                            Text { text: root.appWindow.statusMode === "TPMS" ? root.tr("Simülasyon değerleri · bar", "Simulated values · bar") : root.appWindow.statusMode === "WEIGHT" ? root.tr("Tahmini değerler · OBD verisi değil", "Estimated values · not OBD data") : root.tr("Simülasyon · gerçek araç bağlantısı bekleniyor", "Simulation · waiting for vehicle connection"); color: root.muted; font.pixelSize: 9 }
                            Grid {
                                width: parent.width; columns: 2; spacing: 8; visible: root.appWindow.statusMode === "TPMS"
                                Repeater {
                                    model: [
                                        { name: root.tr("ÖN SOL", "FRONT LEFT"), value: root.tireFL }, { name: root.tr("ÖN SAĞ", "FRONT RIGHT"), value: root.tireFR },
                                        { name: root.tr("ARKA SOL", "REAR LEFT"), value: root.tireRL }, { name: root.tr("ARKA SAĞ", "REAR RIGHT"), value: root.tireRR }
                                    ]
                                    Rectangle {
                                        required property var modelData
                                        width: (parent.width - 8) / 2; height: 62; radius: 13; color: root.panelRaised
                                        Text { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 11; text: modelData.name; color: "#89908E"; font.pixelSize: 8; font.bold: true }
                                        Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 11; anchors.bottomMargin: 9; text: Number(modelData.value).toFixed(1) + " bar"; color: Number(modelData.value) < 2 ? "#B95150" : root.ink; font.pixelSize: 17; font.bold: true; font.family: "Consolas" }
                                    }
                                }
                            }
                            Row {
                                width: parent.width; spacing: 8; visible: root.appWindow.statusMode === "WEIGHT"
                                Repeater {
                                    model: [
                                        { name: root.tr("BOŞ AĞIRLIK", "KERB WEIGHT"), value: root.kerbWeight.toFixed(0) + " kg" },
                                        { name: root.tr("TAHMİN", "ESTIMATE"), value: root.grossWeight.toFixed(0) + " kg" }
                                    ]
                                    Rectangle {
                                        required property var modelData
                                        width: (parent.width - 8) / 2; height: 100; radius: 14; color: root.panelRaised
                                        Text { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 13; text: modelData.name; color: "#89908E"; font.pixelSize: 8; font.bold: true }
                                        Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 13; anchors.bottomMargin: 13; text: modelData.value; color: root.ink; font.pixelSize: 20; font.bold: true }
                                    }
                                }
                            }
                            Grid {
                                width: parent.width; columns: 2; spacing: 8; visible: root.appWindow.statusMode === "DIAGNOSTICS"
                                Repeater {
                                    model: [
                                        { name: root.tr("DEVİR", "RPM"), value: Math.round(root.rpm) + " rpm" }, { name: root.tr("SOĞUTMA", "COOLANT"), value: Math.round(root.coolant) + " °C" },
                                        { name: root.tr("AKÜ", "BATTERY"), value: Number(root.voltage).toFixed(1) + " V" }, { name: root.tr("GAZ", "THROTTLE"), value: Math.round(root.throttle) + "%" }
                                    ]
                                    Rectangle {
                                        required property var modelData
                                        width: (parent.width - 8) / 2; height: 62; radius: 13; color: root.panelRaised
                                        Text { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 11; text: modelData.name; color: "#89908E"; font.pixelSize: 8; font.bold: true }
                                        Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 11; anchors.bottomMargin: 9; text: modelData.value; color: root.ink; font.pixelSize: 16; font.bold: true; font.family: "Consolas" }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            visible: root.activeTab === 2
            anchors.fill: parent
            Row {
                anchors.fill: parent; spacing: 16
                Rectangle {
                    width: parent.width * 0.54; height: parent.height; radius: 22; color: root.panel; border.color: root.stroke
                    Column {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 24; spacing: 8
                            Text { text: root.tr("HIZLANMA ÖLÇER", "ACCELERATION TIMER"); color: root.accent; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.4 }
                        Text { text: root.tr("0 — 100 km/h", "0 — 100 km/h"); color: root.muted; font.pixelSize: 12 }
                        Text { text: Number(root.dragTime).toFixed(2) + " s"; color: root.ink; font.pixelSize: 64; font.weight: Font.Light; font.family: "Consolas" }
                        Text { text: root.tr("EN İYİ  ", "BEST  ") + (root.bestDragTime > 0 ? Number(root.bestDragTime).toFixed(2) + " s" : "—"); color: "#A7B4A8"; font.pixelSize: 12; font.bold: true }
                    }
                    Row {
                        anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 24; spacing: 10
                        Rectangle {
                            width: 144; height: 42; radius: 12; color: root.accent
                            Text { anchors.centerIn: parent; text: root.dragArmed ? root.tr("ÖLÇÜM HAZIR", "READY") : root.tr("ÖLÇÜMÜ KUR", "ARM TIMER"); color: "#171817"; font.pixelSize: 10; font.bold: true }
                            MouseArea { anchors.fill: parent; onClicked: root.vehicleSim.armDragTimer() }
                        }
                        Rectangle {
                            width: 100; height: 42; radius: 12; color: root.panelRaised; border.color: "#343A3B"
                            Text { anchors.centerIn: parent; text: root.tr("SIFIRLA", "RESET"); color: "#C5C9C5"; font.pixelSize: 10; font.bold: true }
                            MouseArea { anchors.fill: parent; onClicked: root.vehicleSim.resetDragTimer() }
                        }
                    }
                }
                Column {
                    width: parent.width * 0.44; height: parent.height; spacing: 12
                    Repeater {
                        model: [
                            { title: root.tr("HIZ", "SPEED"), value: Math.round(root.speed) + " km/h" },
                            { title: root.tr("MOTOR DEVRİ", "ENGINE RPM"), value: Math.round(root.rpm) + " rpm" },
                            { title: root.tr("VERİ KAYNAĞI", "DATA SOURCE"), value: root.hardwareConnected ? "OBD-II" : root.tr("Simülasyon", "Simulation") }
                        ]
                        Rectangle {
                            required property var modelData
                            width: parent.width; height: (parent.height - 24) / 3; radius: 18; color: root.panel; border.color: root.stroke
                            Text { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 18; text: modelData.title; color: root.muted; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                            Text { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.leftMargin: 18; anchors.bottomMargin: 15; text: modelData.value; color: root.ink; font.pixelSize: 23; font.weight: Font.Light }
                        }
                    }
                }
            }
        }

        Item {
            visible: root.activeTab === 3
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent; radius: 22; color: root.panel; border.color: root.stroke
                Column {
                    anchors.centerIn: parent; spacing: 14
                    Rectangle {
                        width: 76; height: 76; radius: 20; color: root.panelRaised; anchors.horizontalCenter: parent.horizontalCenter
                        Text { anchors.centerIn: parent; text: "♫"; color: root.accent; font.pixelSize: 36 }
                    }
                    Text { text: root.tr("MEDYA", "MEDIA"); color: root.ink; font.pixelSize: 21; font.weight: Font.Light; anchors.horizontalCenter: parent.horizontalCenter }
                    Text { text: root.tr("Telefon veya ses kaynağı bağlandığında burada görünür", "Connect a phone or audio source to see it here"); color: root.muted; font.pixelSize: 11; anchors.horizontalCenter: parent.horizontalCenter }
                    Rectangle {
                        width: 174; height: 42; radius: 12; color: root.panelRaised; border.color: "#343A3B"; anchors.horizontalCenter: parent.horizontalCenter
                        Text { anchors.centerIn: parent; text: root.tr("KAYNAK BEKLENİYOR", "WAITING FOR SOURCE"); color: "#AEB3AF"; font.pixelSize: 9; font.bold: true; font.letterSpacing: 0.7 }
                    }
                }
            }
        }

        Item {
            visible: root.activeTab === 4
            anchors.fill: parent
            Row {
                anchors.fill: parent; spacing: 16
                Rectangle {
                    width: parent.width * 0.56; height: parent.height; radius: 22; color: root.panel; border.color: root.stroke
                    Column {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 22; spacing: 8
                        Text { text: root.tr("YOLCULUK BİLGİSİ", "TRIP INFORMATION"); color: root.accent; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1.4 }
                        Text { text: root.tr("Mesafe ve tahmini tüketim", "Distance and estimated fuel use"); color: root.muted; font.pixelSize: 11 }
                        Row {
                            spacing: 40
                            Column {
                                spacing: 6
                                Text { text: root.tr("MESAFE", "DISTANCE"); color: root.muted; font.pixelSize: 9; font.bold: true }
                                Text { text: Number(root.appWindow.liveTripDist).toFixed(2) + " km"; color: root.ink; font.pixelSize: 26; font.weight: Font.Light }
                            }
                            Column {
                                spacing: 6
                                Text { text: root.tr("ORT. TÜKETİM", "AVG. FUEL USE"); color: root.muted; font.pixelSize: 9; font.bold: true }
                                Text { text: root.appWindow.liveTripDist > 0.05 ? ((root.appWindow.liveTripFuel / root.appWindow.liveTripDist) * 100).toFixed(1) + " L/100" : "— L/100"; color: root.ink; font.pixelSize: 26; font.weight: Font.Light }
                            }
                        }
                    }
                    Row {
                        anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 22; spacing: 8
                        Rectangle {
                            width: 126; height: 40; radius: 11; color: root.appWindow.tripActive ? "#453031" : root.accent
                            Text { anchors.centerIn: parent; text: root.appWindow.tripActive ? root.tr("DURDUR", "STOP") : root.tr("BAŞLAT", "START"); color: root.appWindow.tripActive ? "#E6B9B6" : "#171817"; font.pixelSize: 10; font.bold: true }
                            MouseArea { anchors.fill: parent; onClicked: root.appWindow.tripActive = !root.appWindow.tripActive }
                        }
                        Rectangle {
                            width: 108; height: 40; radius: 11; color: root.panelRaised; border.color: "#343A3B"
                            Text { anchors.centerIn: parent; text: root.tr("KAYDET", "SAVE"); color: "#C5C9C5"; font.pixelSize: 10; font.bold: true }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var copy = root.appWindow.savedTripLogs.slice()
                                    var d = root.appWindow.liveTripDist
                                    var avg = d > 0.05 ? ((root.appWindow.liveTripFuel / d) * 100).toFixed(1) : "0.0"
                                    copy.push(d.toFixed(2) + " km · " + avg + " L/100 km")
                                    root.appWindow.savedTripLogs = copy
                                }
                            }
                        }
                        Rectangle {
                            width: 96; height: 40; radius: 11; color: root.panelRaised; border.color: "#343A3B"
                            Text { anchors.centerIn: parent; text: root.tr("SIFIRLA", "RESET"); color: "#AEB3AF"; font.pixelSize: 10; font.bold: true }
                            MouseArea { anchors.fill: parent; onClicked: { root.appWindow.tripActive = false; root.appWindow.liveTripDist = 0; root.appWindow.liveTripFuel = 0 } }
                        }
                    }
                }
                Rectangle {
                    width: parent.width * 0.42; height: parent.height; radius: 22; color: root.panel; border.color: root.stroke
                    Column {
                        anchors.fill: parent; anchors.margins: 20; spacing: 12
                        Text { text: root.tr("KAYITLAR", "SAVED TRIPS"); color: root.ink; font.pixelSize: 12; font.bold: true; font.letterSpacing: 0.8 }
                        ListView {
                            width: parent.width; height: parent.height - 30; clip: true; model: root.appWindow.savedTripLogs; spacing: 7
                            delegate: Rectangle {
                                required property int index; required property var modelData
                                width: ListView.view.width; height: 40; radius: 11; color: root.panelRaised
                                Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 12; text: root.tr("YOLCULUK ", "TRIP ") + (index + 1); color: root.muted; font.pixelSize: 8; font.bold: true }
                                Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 12; text: modelData; color: "#E3E1D9"; font.pixelSize: 9; font.bold: true }
                            }
                        }
                    }
                }
            }
        }

        Item {
            visible: root.activeTab === 5
            anchors.fill: parent
            Row {
                anchors.fill: parent; spacing: 16
                Rectangle {
                    width: parent.width * 0.56; height: parent.height; radius: 22; color: root.panel; border.color: root.stroke
                    Column {
                        anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 22; spacing: 9
                        Text { text: root.tr("ARAYÜZ", "INTERFACE"); color: root.ink; font.pixelSize: 13; font.bold: true }
                        Text { text: root.tr("Dil / Language", "Language / Dil"); color: root.muted; font.pixelSize: 10 }
                        Row {
                            spacing: 8
                            Repeater {
                                model: [{code: "TR", english: false}, {code: "EN", english: true}]
                                Rectangle {
                                    required property var modelData
                                    width: 86; height: 40; radius: 11
                                    color: root.english === modelData.english ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.17) : root.panelRaised
                                    border.color: root.english === modelData.english ? root.accent : root.stroke
                                    Text { anchors.centerIn: parent; text: modelData.code; color: root.english === modelData.english ? root.accent : root.ink; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.appWindow.languageEnglish = modelData.english }
                                }
                            }
                        }
                        Item { width: 1; height: 2 }
                        Text { text: root.tr("VURGU RENGİ", "ACCENT COLOR"); color: root.muted; font.pixelSize: 9; font.bold: true; font.letterSpacing: 1 }
                        Row {
                            spacing: 12
                            Repeater {
                                model: root.themeColors
                                Rectangle {
                                    required property int index; required property var modelData
                                    width: 34; height: 34; radius: 17; color: modelData
                                    border.color: root.themeColorIndex === index ? root.ink : "transparent"; border.width: 2
                                    MouseArea { anchors.fill: parent; onClicked: root.appWindow.themeColorIndex = index }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    width: parent.width * 0.42; height: parent.height; radius: 22; color: root.panel; border.color: root.stroke
                    Column {
                        anchors.fill: parent; anchors.margins: 22; spacing: 12
                        Text { text: root.tr("ARAÇ BAĞLANTISI", "VEHICLE CONNECTION"); color: root.ink; font.pixelSize: 13; font.bold: true }
                        Text { text: root.tr("OBD-II üzerinden okunabilen veriler için temel hazır.", "The interface is ready for data read through OBD-II."); color: root.muted; font.pixelSize: 10; wrapMode: Text.WordWrap; width: parent.width }
                        Rectangle { width: parent.width; height: 1; color: root.stroke }
                        Row {
                            spacing: 8
                            Rectangle { width: 8; height: 8; radius: 4; color: root.hardwareConnected ? "#A7B4A8" : root.accent; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: root.hardwareConnected ? root.tr("Araç bağlı", "Vehicle connected") : root.tr("Simülasyon modu", "Simulation mode"); color: "#D7D8D2"; font.pixelSize: 11; font.bold: true }
                        }
                        Text { text: root.hardwareConnected ? root.rawPacket : root.tr("Gerçek araç verisi henüz bağlı değil.", "Live vehicle data is not connected yet."); color: "#777E7C"; font.pixelSize: 9; wrapMode: Text.WordWrap; width: parent.width }
                    }
                }
            }
        }
    }
}
