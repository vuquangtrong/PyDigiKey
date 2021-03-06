import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12
import QtGraphicalEffects 1.12 as QtGraphicalEffects
import Location 1.0
import Anchor 1.0
import BLE 1.0
import Params 1.0
import Performance 1.0

Item {
    id: root
    width: 1920
    height: 1080

    readonly property real transitionDuration: 200 // ms

    RowLayout {
        anchors.fill: parent    
        spacing: 0

        // view
        Item {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item {
                id: canvas 
                property double scaleFactor: canvas_transform.xScale

                /* 1px = 1cm */
                /* input unit is meter */

                /*** TRANSLATE IS USED FOR OBJECTS ***/
                function translateX(obj, ix) {
                    return ix*100 + (canvas.width- obj.width) / 2
                }

                function translateY(obj, iy) {
                    // y is reversed with screen y-axis
                    return -iy*100 + (canvas.height - obj.height) / 2
                }
                
                /*** CONVERT IS USED FOR POINTS IN SHAPE PATH */
                function convertX(ix) {
                    return ix + (canvas.width / 2)
                }

                function convertY(iy) {
                    return iy + (canvas.height / 2)
                }

                /* Encapsulate graph */
                width: 3000 // cm
                height: 3000 // cm

                /* Move "camera" to center */
                x: (-width + view.width) / 2
                y: (-height + view.height) / 2 + 120

                Item {
                    id: car
                    

                    /*
                    width: 180
                    height: 460
                    x: 1460
                    y: 1080
                    */
                    z: car_resizer.visible ? 1000 : 0

                    Component.onCompleted: {
                        car.width = DigiKeyFromLog.car.width
                        car.height = DigiKeyFromLog.car.height
                        car.x = DigiKeyFromLog.car.x + canvas.width/2
                        car.y = DigiKeyFromLog.car.y + canvas.height/2
                    }

                    Image {
                        id: image_car
                        anchors.fill: parent
                        source: "car.png"
                        opacity: car_resizer.visible ? 0.5: 0.25
                    }

                    QtGraphicalEffects.ColorOverlay {
                        anchors.fill: image_car
                        source: image_car
                        color: "#4000ff00"
                        visible: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 0) : false
                    }

                    Rectangle {
                        id: car_resizer
                        anchors.fill: parent
                        color: "transparent"
                        border.color: "steelblue"
                        border.width: 2
                        visible: false

                        MouseArea {
                            anchors.fill: parent
                            drag.target: car
                            acceptedButtons: Qt.LeftButton
                            propagateComposedEvents: false
                        }

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: "steelblue"
                            anchors.horizontalCenter: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                anchors.fill: parent
                                drag{ target: parent; axis: Drag.XAxis }
                                acceptedButtons: Qt.LeftButton
                                propagateComposedEvents: false

                                onMouseXChanged: {
                                    if(drag.active){
                                        car.width = car.width - mouseX
                                        car.x = car.x + mouseX
                                        if(car.width < 30)
                                            car.width = 30
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: "steelblue"
                            anchors.horizontalCenter: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                anchors.fill: parent
                                drag{ target: parent; axis: Drag.XAxis }
                                acceptedButtons: Qt.LeftButton
                                propagateComposedEvents: false

                                onMouseXChanged: {
                                    if(drag.active){
                                        car.width = car.width + mouseX
                                        if(car.width < 30)
                                            car.width = 30
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: "steelblue"
                            x: parent.x / 2
                            y: 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.top

                            MouseArea {
                                anchors.fill: parent
                                drag{ target: parent; axis: Drag.YAxis }
                                acceptedButtons: Qt.LeftButton
                                propagateComposedEvents: false

                                onMouseYChanged: {
                                    if(drag.active){
                                        car.height = car.height - mouseY
                                        car.y = car.y + mouseY
                                        if(car.height < 30)
                                            car.height = 30
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: "steelblue"
                            x: parent.x / 2
                            y: parent.y
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.bottom

                            MouseArea {
                                anchors.fill: parent
                                drag{ target: parent; axis: Drag.YAxis }
                                acceptedButtons: Qt.LeftButton
                                propagateComposedEvents: false

                                onMouseYChanged: {
                                    if(drag.active){
                                        car.height = car.height + mouseY
                                        if(car.height < 30)
                                            car.height = 30
                                    }
                                }
                            }
                        }
                    }  
                }
                
                GridLine {
                    anchors.fill: parent // must be the same size with canvas
                    opacity: 0.25
                    lineSpace: 100 // cm
                    lineColor: "red"
                    lineWidthFactor: canvas.scaleFactor
                }

                GridLine {
                    anchors.fill: parent // must be the same size with canvas
                    opacity: 0.1
                    lineSpace: 50 // cm 
                    lineColor: "red"
                    lineWidthFactor: canvas.scaleFactor
                    visible: canvas.scaleFactor >= 0.25 && canvas.scaleFactor < 0.5
                }

                GridLine {
                    anchors.fill: parent // must be the same size with canvas
                    opacity: 0.1
                    lineSpace: 20 // cm 
                    lineColor: "blue"
                    lineWidthFactor: canvas.scaleFactor
                    visible: canvas.scaleFactor >= 0.5 && canvas.scaleFactor < 2
                }

                GridLine {
                    anchors.fill: parent // must be the same size with canvas
                    opacity: 0.1
                    lineSpace: 10 // cm 
                    lineColor: "blue"
                    lineWidthFactor: canvas.scaleFactor
                    visible: canvas.scaleFactor >= 2
                }

                // Reference points
                Repeater {
                    property var refer_points: []

                    model: refer_points

                    Rectangle {
                        id: refer_point
                        opacity: 0.25
                        width: 6 / canvas.scaleFactor
                        height: 6 / canvas.scaleFactor
                        radius: 3 / canvas.scaleFactor
                        color: "purple"
                        x: canvas.translateX(refer_point, modelData.px)
                        y: canvas.translateY(refer_point, modelData.py)

                        Text {
                            id: refer_point_name
                            x: parent.width
                            y: parent.height
                            color: "purple"
                            text: "" + modelData.px + "," + modelData.py
                        }
                    }

                    Component.onCompleted: {
                        for(var u=-15; u<=15; u+=5) {
                            for(var v=-15; v<=15; v+=5) {
                                refer_points.push({
                                    px: u,
                                    py: v
                                })
                            }
                        }
                        // notify
                        refer_pointsChanged()
                    }
                }

                // Anchors
                Repeater {
                    model: DigiKeyFromLog.anchors.length

                    Rectangle {
                        id: anchor
                        width: 10 / canvas.scaleFactor
                        height: 10 / canvas.scaleFactor
                        radius: 5 / canvas.scaleFactor
                        color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.activatedAnchors[index] ? "red" : "black") : "black"
                        x: canvas.translateX(anchor, DigiKeyFromLog.anchors[index].coordinate[0])
                        y: canvas.translateY(anchor, DigiKeyFromLog.anchors[index].coordinate[1])
                        visible: DigiKeyFromLog.anchors[index].isWorking
                        
                        Text {
                            id: anchor_name
                            x: parent.width
                            y: parent.height
                            color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.activatedAnchors[index] ? "red" : "black") : "black"
                            text: "A" + (index+1)

                            Text {
                                id: anchor_info
                                x: 0
                                y: parent.height
                                text: DigiKeyFromLog.anchors[index].coordinate[0].toFixed(2) + "," + 
                                      DigiKeyFromLog.anchors[index].coordinate[1].toFixed(2)
                                visible: false
                            }

                            MouseArea {
                                anchors.fill: parent
                                
                                onClicked: {
                                    anchor_info.visible = !anchor_info.visible
                                }
                            }
                        }
                    }
                }

                Item {
                    id: ble
                    property int radius: 1000 // cm

                    width: 2*radius
                    height: 2*radius
                    z: ble_resizer.visible ? 1000 : 0
                    visible: sw_ble_zone.checked

                    Component.onCompleted: {
                        ble.radius = DigiKeyFromLog.ble.radius
                        ble.x = DigiKeyFromLog.ble.x + canvas.width/2 - ble.radius
                        ble.y = DigiKeyFromLog.ble.y + canvas.height/2 - ble.radius
                    }

                    Shape {
                        anchors.fill: parent
                        opacity: ble_resizer.visible ? 0.5 : 0.25

                        ShapePath {

                            fillGradient: RadialGradient {
                                centerX: ble.width/2
                                centerY: ble.height/2
                                centerRadius: ble.width/2
                                focalX: centerX
                                focalY: centerY
                                GradientStop { position: 0; color: "transparent" }
                                GradientStop { position: 0.8; color: "#0F3498DB" }
                                GradientStop { position: 1; color: "#7F3498DB" }
                            }

                            PathAngleArc {
                                moveToStart: true
                                centerX: ble.width/2
                                centerY: ble.height/2
                                radiusX: ble.width/2
                                radiusY: ble.width/2
                                startAngle: 0
                                sweepAngle: 360
                            }    
                        }
                    }

                    Rectangle {
                        id: ble_resizer
                        anchors.fill: parent
                        color: "transparent"
                        visible: false

                        MouseArea {
                            anchors.fill: parent
                            drag.target: ble
                            acceptedButtons: Qt.LeftButton
                            propagateComposedEvents: false
                        }

                        /*
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: "steelblue"
                            anchors.horizontalCenter: parent.left
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                anchors.fill: parent
                                drag{ target: parent; axis: Drag.XAxis }
                                acceptedButtons: Qt.LeftButton
                                propagateComposedEvents: false

                                onMouseXChanged: {
                                    if(drag.active){
                                        ble.width = ble.width - mouseX
                                        ble.x = ble.x + mouseX
                                        if(ble.width < 30)
                                            ble.width = 30
                                    }
                                }
                            }
                        }
                        */

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: "steelblue"
                            anchors.horizontalCenter: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            MouseArea {
                                anchors.fill: parent
                                drag{ target: parent; axis: Drag.XAxis }
                                acceptedButtons: Qt.LeftButton
                                propagateComposedEvents: false

                                onMouseXChanged: {
                                    if(drag.active){
                                        ble.width = ble.width + mouseX
                                        if(ble.width < 30)
                                            ble.width = 30
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    id: zones
                    anchors.fill: parent
                    
                    property int offsetX: 10 // cm
                    property int offsetY: 10 // cm
                    property int distanceNear: 150 // cm
                    property int distanceFar: 300 // cm

                    property var anchorA: [car.x + zones.offsetX, car.y + zones.offsetY]
                    property var anchorB: [car.x + car.width - zones.offsetX, car.y + zones.offsetY]
                    property var anchorC: [car.x + zones.offsetX, car.y + car.height - zones.offsetY]
                    property var anchorD: [car.x + car.width - zones.offsetX, car.y + car.height - zones.offsetY]

                    Shape {
                        opacity: 0.4

                        /*                        
                        ShapePath {
                            id: zone_0_center

                            // there is an issue that does not trigger binding if using transparent color in expression ???
                            // use "#01000000" for transparent
                            fillColor: DigiKeyFromLog.currentLocation.zone == 0 ? "blue" : "#01000000"
                            strokeColor: "transparent"
                            startX: zones.anchorA[0]
                            startY: zones.anchorA[1]

                            PathLine {
                                x: zones.anchorB[0]
                                y: zones.anchorB[1]
                            }

                            PathLine {
                                x: zones.anchorD[0]
                                y: zones.anchorD[1]
                            }

                            PathLine {
                                x: zones.anchorC[0]
                                y: zones.anchorC[1]
                            }
                        }
                        */

                        Zone {
                            id: zone_1_front_near
                            //fillColor: DigiKeyFromLog.currentLocation.zone == 1 ? "green" : "#01000000"
                            fillGradient: LinearGradient {
                                x1: zones.anchorA[0]
                                y1: zones.anchorA[1]
                                x2: zones.anchorA[0]
                                y2: zones.anchorA[1] - zones.distanceNear
                                GradientStop { position: 0; color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 1 ? "green" : "transparent") : "transparent" }
                                GradientStop { position: 1; color: "transparent" }
                            }
                            strokeColor: "transparent"
                            pointA: zones.anchorA
                            pointB: zones.anchorB
                            arcA: [-45, -45]
                            arcB: [-90, -45]
                            arcR: zones.distanceNear
                        }

                        Zone {
                            id: zone_2_front_far
                            //fillColor: DigiKeyFromLog.currentLocation.zone == 2 ? "yellow" : "#01000000"
                            fillGradient: LinearGradient {
                                x1: zones.anchorA[0]
                                y1: zones.anchorA[1]
                                x2: zones.anchorA[0]
                                y2: zones.anchorA[1] - zones.distanceFar
                                GradientStop { position: 0; color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 2 ? "yellow" : "transparent") : "transparent" }
                                GradientStop { position: 1; color: "transparent" }
                            }
                            strokeColor: "transparent"
                            pointA: zones.anchorA
                            pointB: zones.anchorB
                            arcA: [-45, -45]
                            arcB: [-90, -45]
                            arcR: zones.distanceFar
                        }

                        Zone {
                            id: zone_3_left_near
                            //fillColor: DigiKeyFromLog.currentLocation.zone == 3 ? "green" : "#01000000"
                            fillGradient: LinearGradient {
                                x1: zones.anchorA[0]
                                y1: zones.anchorA[1]
                                x2: zones.anchorA[0] - zones.distanceNear
                                y2: zones.anchorA[1]
                                GradientStop { position: 0; color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 3 ? "green" : "transparent") : "transparent"}
                                GradientStop { position: 1; color: "transparent" }
                            }
                            strokeColor: "transparent"
                            pointA: zones.anchorA
                            pointB: zones.anchorC
                            arcA: [135, 45]
                            arcB: [180, 45]
                            arcR: zones.distanceNear
                        }

                        Zone {
                            id: zone_4_left_far
                            //fillColor: DigiKeyFromLog.currentLocation.zone == 4 ? "yellow" : "#01000000"
                            fillGradient: LinearGradient {
                                x1: zones.anchorA[0]
                                y1: zones.anchorA[1]
                                x2: zones.anchorA[0] - zones.distanceFar
                                y2: zones.anchorA[1]
                                GradientStop { position: 0; color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 4 ? "yellow" : "transparent") : "transparent"}
                                GradientStop { position: 1; color: "transparent" }
                            }
                            strokeColor: "transparent"
                            pointA: zones.anchorA
                            pointB: zones.anchorC
                            arcA: [135, 45]
                            arcB: [180, 45]
                            arcR: zones.distanceFar
                        }

                        Zone {
                            id: zone_5_rear_near
                            //fillColor: DigiKeyFromLog.currentLocation.zone == 5 ? "green" : "#01000000"
                            fillGradient: LinearGradient {
                                x1: zones.anchorC[0]
                                y1: zones.anchorC[1]
                                x2: zones.anchorC[0]
                                y2: zones.anchorC[1] + zones.distanceNear
                                GradientStop { position: 0; color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 5 ? "green" : "transparent") : "transparent" }
                                GradientStop { position: 1; color: "transparent" }
                            }
                            strokeColor: "transparent"
                            pointA: zones.anchorC
                            pointB: zones.anchorD
                            arcA: [45, 45]
                            arcB: [90, 45]
                            arcR: zones.distanceNear
                        }

                        Zone {
                            id: zone_6_rear_far
                            //fillColor: DigiKeyFromLog.currentLocation.zone == 6 ? "yellow" : "#01000000"
                            fillGradient: LinearGradient {
                                x1: zones.anchorC[0]
                                y1: zones.anchorC[1]
                                x2: zones.anchorC[0]
                                y2: zones.anchorC[1] + zones.distanceFar
                                GradientStop { position: 0; color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 6 ? "yellow" : "transparent") : "transparent"}
                                GradientStop { position: 1; color: "transparent" }
                            }
                            strokeColor: "transparent"
                            pointA: zones.anchorC
                            pointB: zones.anchorD
                            arcA: [45, 45]
                            arcB: [90, 45]
                            arcR: zones.distanceFar
                        }

                        Zone {
                            id: zone_7_left_near
                            //fillColor: DigiKeyFromLog.currentLocation.zone == 7 ? "green" : "#01000000"
                            fillGradient: LinearGradient {
                                x1: zones.anchorB[0]
                                y1: zones.anchorB[1]
                                x2: zones.anchorB[0] + zones.distanceNear
                                y2: zones.anchorB[1]
                                GradientStop { position: 0; color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 7 ? "green" : "transparent") : "transparent"}
                                GradientStop { position: 1; color: "transparent" }
                            }
                            strokeColor: "transparent"
                            pointA: zones.anchorB
                            pointB: zones.anchorD
                            arcA: [45, -45]
                            arcB: [0, -45]
                            arcR: zones.distanceNear
                        }

                        Zone {
                            id: zone_8_left_far
                            //fillColor: DigiKeyFromLog.currentLocation.zone == 8 ? "yellow" : "#01000000"
                            fillGradient: LinearGradient {
                                x1: zones.anchorB[0]
                                y1: zones.anchorB[1]
                                x2: zones.anchorB[0] + zones.distanceFar
                                y2: zones.anchorB[1]
                                GradientStop { position: 0; color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.zone == 8 ? "yellow" : "transparent") : "transparent"}
                                GradientStop { position: 1; color: "transparent" }
                            }
                            strokeColor: "transparent"
                            pointA: zones.anchorB
                            pointB: zones.anchorD
                            arcA: [45, -45]
                            arcB: [0, -45]
                            arcR: zones.distanceFar
                        }
                    }
                }

                // Show history lines
                Shape {
                    anchors.fill: parent
                    opacity: 0.4
                    visible: show_trace.checked

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: "darkblue"
                        strokeWidth: 1 / canvas.scaleFactor

                        PathSvg { 
                            id: historyLocation; 
                            path: ""
                        }
                    }

                    Connections {
                        target: DigiKeyFromLog
                        function onCurrentLocationChanged() {
                            // only show last 10 locations
                            var start_index = DigiKeyFromLog.currentLocationIndex - 10
                            if (start_index < 0) {
                                start_index = 0
                            }

                            // move to the first point
                            var paths = "M %1 %2 ".arg(canvas.width/2 + 100*DigiKeyFromLog.locations[start_index].coordinate[0])
                                                .arg(canvas.height/2 - 100*DigiKeyFromLog.locations[start_index].coordinate[1])
                            // draw Line to next points
                            for(var i = start_index + 1; i <= DigiKeyFromLog.currentLocationIndex; i++) {
                                paths += "L %1 %2 ".arg(canvas.width/2 + 100*DigiKeyFromLog.locations[i].coordinate[0])
                                                .arg(canvas.height/2 - 100*DigiKeyFromLog.locations[i].coordinate[1]);
                            }

                            historyLocation.path = paths
                        }
                    }
                }

                // Current location 
                Rectangle {
                    id: current_location
                    width: 10 / canvas.scaleFactor
                    height: 10 / canvas.scaleFactor
                    radius: 5 / canvas.scaleFactor
                    color: "red"
                    x: canvas.translateX(current_location, DigiKeyFromLog.currentLocation.coordinate[0])
                    y: canvas.translateY(current_location, DigiKeyFromLog.currentLocation.coordinate[1])

                    Text {
                        id: anchor_name
                        x: parent.width
                        y: parent.height
                        color: "red"
                        font.pointSize: canvas.scaleFactor >= 1 ? 12 : 12 / canvas.scaleFactor
                        text: "#" + (DigiKeyFromLog.currentLocationIndex + 1)

                        Text {
                            x: 0
                            y: parent.height
                            color: "red"
                            font.pointSize: canvas.scaleFactor >= 1 ? 12 : 12 / canvas.scaleFactor
                            text: DigiKeyFromLog.currentLocation.coordinate[0].toFixed(2) + "," +
                                  DigiKeyFromLog.currentLocation.coordinate[1].toFixed(2)
                        }
                    }
                }

                // Current location uncertanty circles
                Rectangle {
                    id: current_location_around_10
                    width: 20
                    height: 20
                    radius: 10
                    color: "transparent"
                    border.color: "blue"
                    border.width: 1.0
                    x: canvas.translateX(current_location_around_10, DigiKeyFromLog.currentLocation.coordinate[0])
                    y: canvas.translateY(current_location_around_10, DigiKeyFromLog.currentLocation.coordinate[1])
                    opacity: 0.5
                    visible: canvas.scaleFactor >= 1
                }

                MouseArea {
                    id: canvas_mouse
                    anchors.fill: parent
                    //propagateComposedEvents: true
                    
                    // Make canvas draggable
                    drag.target: canvas
                    acceptedButtons: Qt.LeftButton

                    property double factor: 2

                    onWheel: {
                        // limit zoomable level
                        if ((canvas_transform.xScale > 4  && wheel.angleDelta.y > 0)
                            || (canvas_transform.xScale < 1/4 && wheel.angleDelta.y < 0 )) 
                            return

                        // if zoomable, calculate zoom factor
                        var zoomFactor = wheel.angleDelta.y > 0 ? factor : 1 / factor
                        var realX = wheel.x * canvas_transform.xScale
                        var realY = wheel.y * canvas_transform.yScale
                        canvas.x += (1 - zoomFactor) * realX
                        canvas.y += (1 - zoomFactor) * realY
                        canvas_transform.xScale *= zoomFactor
                        canvas_transform.yScale *= zoomFactor
                    }
                }

                transform: Scale {
                    id: canvas_transform

                    Behavior on xScale { PropertyAnimation { duration: transitionDuration;  easing.type: Easing.InOutCubic } }
                    Behavior on yScale { PropertyAnimation { duration: transitionDuration;  easing.type: Easing.InOutCubic } }
                }

                Behavior on x { PropertyAnimation { duration: transitionDuration; easing.type: Easing.InOutCubic } }
                Behavior on y { PropertyAnimation { duration: transitionDuration; easing.type: Easing.InOutCubic } }
            }

            
            Column {
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                spacing: 2

                Switch {
                    id: show_trace
                    text: "Show Trace"
                    checked: true
                }

                CheckBox { 
                    id: ble_resizable
                    text: "Set BLE zone"
                    visible: sw_ble_zone.checked

                    onClicked: {
                        if (checked) {
                            ble_resizer.visible = true
                        } else {
                            ble_resizer.visible = false
                            DigiKeyFromLog.ble.radius = ble.radius
                            DigiKeyFromLog.ble.x = ble.x - canvas.width/2 + ble.radius
                            DigiKeyFromLog.ble.y = ble.y - canvas.height/2 + ble.radius
                            DigiKeyFromLog.save_ble_zone()
                        }
                    }
                }

                Row {
                    visible: ble_resizable.checked
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        text: "BLE X (cm):"
                    }
                    TextField {
                        width: 50
                        height: 30
                        text:  ble.x.toFixed(0) - canvas.width/2 + ble.radius

                        onEditingFinished: {
                            ble.x = parseInt(text) + canvas.width/2 - ble.radius
                        }
                    }
                }

                Row {
                    visible: ble_resizable.checked
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        text: "BLE Y (cm):"
                    }
                    TextField {
                        width: 50
                        height: 30
                        text:  ble.y.toFixed(0) - canvas.height/2 + ble.radius

                        onEditingFinished: {
                            ble.y = parseInt(text) + canvas.height/2 - ble.radius
                        }
                    }
                }

                Row {
                    visible: ble_resizable.checked
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        text: "BLE Radius (cm):"
                    }
                    TextField {
                        width: 50
                        height: 30
                        text:  (ble.width/2).toFixed(0)

                        onEditingFinished: {
                            ble.width = parseInt(text)*2
                        }
                    }
                }

                CheckBox { 
                    id: car_resizable
                    text: "Set Car location"

                    onClicked: {
                        if (checked) {
                            car_resizer.visible = true
                        } else {
                            car_resizer.visible = false
                            DigiKeyFromLog.car.width = car.width
                            DigiKeyFromLog.car.height = car.height
                            DigiKeyFromLog.car.x = car.x - canvas.width/2
                            DigiKeyFromLog.car.y = car.y - canvas.height/2
                            DigiKeyFromLog.save_car_location()
                        }
                    }
                }

                Row {
                    visible: car_resizable.checked
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        text: "Car Width (cm):"
                    }
                    TextField {
                        width: 50
                        height: 30
                        text:  car.width.toFixed(0)

                        onEditingFinished: {
                            car.width = parseInt(text)
                        }
                    }
                }

                Row {
                    visible: car_resizable.checked
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        text: "Car Height (cm):"
                    }
                    TextField {
                        width: 50
                        height: 30
                        text:  car.height.toFixed(0)

                        onEditingFinished: {
                            car.height = parseInt(text)
                        }
                    }
                }

                Row {
                    visible: car_resizable.checked
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        text: "Car X (cm):"
                    }
                    TextField {
                        width: 50
                        height: 30
                        text:  car.x.toFixed(0) - canvas.width/2

                        onEditingFinished: {
                            car.x = parseInt(text) + canvas.width/2
                        }
                    }
                }

                Row {
                    visible: car_resizable.checked
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 100
                        text: "Car Y (cm):"
                    }
                    TextField {
                        width: 50
                        height: 30
                        text:  car.y.toFixed(0) - canvas.height/2

                        onEditingFinished: {
                            car.y = parseInt(text) + canvas.height/2
                        }
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 5
                text: "Showing location #" + (DigiKeyFromLog.currentLocationIndex + 1) + " of " + DigiKeyFromLog.totalLocations
            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 20
                visible: !car_resizable.checked && !ble_resizable.checked

                Button {
                    text: DigiKeyFromLog.isAutoplay ? "Manual Navigation" : "Autoplay"
                    
                    onClicked: {
                        DigiKeyFromLog.toggle_autoplay()
                    }
                }

                Button {
                    text: "Previous"
                    visible: !DigiKeyFromLog.isAutoplay
                    
                    onClicked: {
                        DigiKeyFromLog.show_previous_location()
                    }
                }

                Button {
                    text: "Next"
                    visible: ! DigiKeyFromLog.isAutoplay
                    
                    onClicked: {
                        DigiKeyFromLog.show_next_location()
                    }
                }
            }
        }

        // settings
        RowLayout {
            Layout.fillHeight: true
            spacing: 0

            // drawer
            Rectangle {
                Layout.preferredWidth: 20
                Layout.fillHeight: true
                color: "#E6E9ED"
                border.color: "#687D91"

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        settings.visible = !settings.visible
                    }

                    onWheel: {}
                }

                Text {
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    rotation: -90
                    text: (settings.visible ? "\u25BC" : "\u25B2") + "Settings & Log" + (settings.visible ? "\u25BC" : "\u25B2")
                    color: "blue"
                }
            }

            Rectangle {
                id: settings
                Layout.preferredWidth: 400
                Layout.fillHeight: true
                border.color: "#687D91"

                MouseArea {
                    anchors.fill: parent
                    
                    onWheel: {}
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 1
                    // Header: Params
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "#E6E9ED"

                        RowLayout {
                            anchors.fill: parent
                            
                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                color: "blue"
                                font.pointSize: 10
                                text: "Params:"
                            }
                        }
                    }

                    RowLayout {
                        enabled: false

                        Item {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 30
                        }

                        Text {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            // leftPadding: 10
                            verticalAlignment: Text.AlignVCenter
                            text: "N"
                        }

                        TextField {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 30
                            text: DigiKeyFromLog.params.N
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            verticalAlignment: Text.AlignVCenter
                            text: "F"
                        }

                        ComboBox {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 30
                            property var items: ["CH5 - 6489600", "CH6 - 6988800", "CH7 - 6489600", "CH8 - 7488000", "CH9 - 7987200"]
                            model: items
                            currentIndex: {
                                var f = "" + DigiKeyFromLog.params.F
                                for (var i=0; i<items.length; i++) {
                                    if (items[i].includes(f)) {
                                        return i
                                    }
                                }
                                return -1
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        enabled: false

                        Item {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 30
                        }

                        Text {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            // leftPadding: 10
                            verticalAlignment: Text.AlignVCenter
                            text: "R"
                        }

                        ComboBox {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 30
                            property var items: ["0", "1", "2", "3", "4", "5", "6", "7"]
                            model: items
                            currentIndex: {
                                var r = "" + DigiKeyFromLog.params.R
                                for (var i=0; i<items.length; i++) {
                                    if (items[i].startsWith(r)) {
                                        return i
                                    }
                                }
                                return -1
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            verticalAlignment: Text.AlignVCenter
                            text: "P"
                        }

                        ComboBox {
                            Layout.preferredWidth: 150
                            Layout.preferredHeight: 30
                            property var items: ["-12 dBm", "-11 dBm", "-10 dBm", "-9 dBm", "-8 dBm", "-7 dBm", "-6 dBm", "-5 dBm", "-6 dBm", "-5 dBm", "-4 dBm", "-3 dBm", "-2 dBm", "-1 dBm", "0 dBm", "1 dBm", "2 dBm", "3 dBm", "4 dBm", "5 dBm", "6 dBm", "7 dBm", "8 dBm", "9 dBm", "10 dBm", "11 dBm", "12 dBm", "13 dBm", "14 dBm"]
                            model: items
                            currentIndex: {
                                var p = "" + DigiKeyFromLog.params.P + " dBm"
                                for (var i=0; i<items.length; i++) {
                                    if (items[i].startsWith(p)) {
                                        return i
                                    }
                                }
                                return -1
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    // Header: Anchors
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "#E6E9ED"

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 5
                            color: "blue"
                            font.pointSize: 10
                            text: "Anchors"
                        }

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment:Text.AlignRight
                            rightPadding: 5
                            text: (anchors.visible ? "Hide \u25B2" : "Show \u25BC")
                            color: "darkblue"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                anchors.visible = !anchors.visible
                            }
                        }
                    }

                    // Anchors
                    GridLayout {
                        id: anchors
                        rows: 4
                        columns: 2
                        enabled: false
                        visible: false

                        Repeater {
                            model: 8
                            RowLayout {
                                spacing: 2

                                CheckBox {
                                    Layout.preferredWidth: 20
                                    Layout.preferredHeight: 30
                                    scale: 0.5
                                    checked: DigiKeyFromLog.anchors[index].isWorking
                                    onClicked: {
                                        DigiKeyFromLog.anchors[index].isWorking = checked
                                    }
                                }

                                Text {
                                    Layout.preferredWidth: 30
                                    Layout.preferredHeight: 30
                                    height: parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    text: "A" + (index + 1)
                                    color: DigiKeyFromLog.currentLocation ? (DigiKeyFromLog.currentLocation.activatedAnchors[index] ? "red" : "black") : "black"
                                }

                                TextField {
                                    Layout.preferredWidth: 45
                                    Layout.preferredHeight: 30
                                    height: parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    validator: DoubleValidator {bottom: -15.0; top: 15.0}
                                    text: DigiKeyFromLog.anchors[index].coordinate[0].toFixed(2)
                                }

                                TextField {
                                    Layout.preferredWidth: 45
                                    Layout.preferredHeight: 30
                                    height: parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    validator: DoubleValidator {bottom: -15.0; top: 15.0}
                                    text: DigiKeyFromLog.anchors[index].coordinate[1].toFixed(2)
                                }

                                TextField {
                                    Layout.preferredWidth: 45
                                    Layout.preferredHeight: 30
                                    height: parent.height
                                    verticalAlignment: Text.AlignVCenter
                                    validator: DoubleValidator {bottom: -15.0; top: 15.0}
                                    text: DigiKeyFromLog.anchors[index].coordinate[2].toFixed(2)
                                }
                            }
                        }
                    }

                    // Header: Params
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "#E6E9ED"

                        RowLayout {
                            anchors.fill: parent
                            
                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                color: "blue"
                                font.pointSize: 10
                                text: "Receiver Performance"
                            }

                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                text: "at location " + (DigiKeyFromLog.currentLocationIndex + 1)
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        wrapMode: Text.WordWrap
                        text: {
                            var msg = ""
                            for(var i=0; i<8; i++) {
                                if(DigiKeyFromLog.anchors[i].isWorking) {
                                    if (msg != "")
                                        msg += "<br>"
                                    msg += "A" + (i+1) + ": "
                                    msg += "F = <font color='green'>" + DigiKeyFromLog.currentLocation.performance[i].RSSI.toFixed(0) + " dBm</font>,  "
                                    msg += "M = <font color='green'>" + DigiKeyFromLog.currentLocation.performance[i].MPWR.toFixed(0) + " dBm</font>,  "
                                    msg += "Fi = <font color='green'>" + DigiKeyFromLog.currentLocation.performance[i].NEV + "</font>,  "
                                    msg += "Mi = <font color='green'>" + DigiKeyFromLog.currentLocation.performance[i].NER + "</font>,  "
                                    msg += "T = <font color='green'>" + DigiKeyFromLog.currentLocation.performance[i].PER.toFixed(0) + " dBm</font>"
                                }
                            }

                            return msg
                        }
                    }

                    // Header: BLE info
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: "#E6E9ED"

                        RowLayout {
                            anchors.fill: parent
                            
                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                color: "blue"
                                font.pointSize: 10
                                text: "BLE Status:"
                            }

                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                font.bold: true
                                font.pointSize: 12
                                text: {
                                    var status = DigiKeyFromLog.ble.status
                                    if ( status == 1) {
                                        return "Disconnected"
                                    } else if (status == 2) {
                                        return "Connecting"
                                    } else if (status == 3) {
                                        return "Connected"
                                    } else {
                                        return "Unknown"
                                    }
                                }
                                color: {
                                    var status = DigiKeyFromLog.ble.status
                                    if ( status == 1) {
                                        return "red"
                                    } else if (status == 2) {
                                        return "orange"
                                    } else if (status == 3) {
                                        return "green"
                                    } else {
                                        return "black"
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            
                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                color: "blue"
                                font.pointSize: 10
                                text: "RSSI (dBm):"
                            }

                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                font.bold: true
                                font.pointSize: 12
                                text: DigiKeyFromLog.ble.rssi
                                color: {
                                    var status = DigiKeyFromLog.ble.status
                                    if ( status == 1) {
                                        return "red"
                                    } else if (status == 2) {
                                        return "orange"
                                    } else if (status == 3) {
                                        return "green"
                                    } else {
                                        return "black"
                                    }
                                }
                            }
                            
                            /*
                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                color: "blue"
                                font.pointSize: 10
                                text: "BLE Zone:"
                            }
                            */

                            Switch {
                                id: sw_ble_zone
                                scale: 0.5
                                checked: DigiKeyFromLog.isShowingBleZone
                                visible: false
                            }
                            
                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // BLE buttons
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30

                        RowLayout {
                            anchors.fill: parent
                            /*
                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                text: "<font color='blue'>RSSI (dBm)</font><br><font color='blue' size='+2'>" + DigiKeyFromLog.ble.rssi + "</font>"
                            }
                            */

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                //Layout.preferredWidth: 20
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                text: "Button count:<br><font color='blue' size='+2'>&nbsp;</font>"
                            }

                            Text {
                                Layout.preferredWidth: 50
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                text: "Door<br><font color='blue' size='+2'>" + DigiKeyFromLog.ble.doorCount + "</font>"
                            }

                            Text {
                                Layout.preferredWidth: 50
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                text: "Trunk<br><font color='blue' size='+2'>" + DigiKeyFromLog.ble.trunkCount + "</font>"
                            }

                            Text {
                                Layout.preferredWidth: 50
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                text: "Engine<br><font color='blue' size='+2'>" + DigiKeyFromLog.ble.engineCount + "</font>"
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Header: Position and Distance
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        color: "#E6E9ED"

                        RowLayout {
                            anchors.fill: parent
                            
                            Text {
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                color: "blue"
                                font.pointSize: 10
                                text: "Location and Distance:"
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Location List
                    ListView {
                        id: location_list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        ScrollBar.vertical: ScrollBar {}
                        clip: true
                        currentIndex: DigiKeyFromLog.currentLocationIndex
                        model: DigiKeyFromLog.locations
                        delegate: Rectangle {
                            width: location_list.width
                            height: 60
                            color: ListView.isCurrentItem ? "yellow" : "transparent"

                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                text: {
                                    var msg = "Location <font size='+1'>" + (index + 1) + "</font>: "
                                    msg += "<font color='blue' size='+1'>"
                                    msg += modelData.coordinate[0].toFixed(2) + ", "
                                    msg += modelData.coordinate[1].toFixed(2)
                                    msg += "</font> "
                                    msg += "in zone: <font color='blue' size='+1'>" + modelData.zone + "</font>"
                                    msg += "<br>"
                                    for(var i=0; i<8; i++) {
                                        var d = modelData.distance[i]
                                        msg += "D" + (i+1) + " = " + ((isNaN(d) || d < 0) ? "<font color='gray'>failed" : "<font color='green'>" + d.toFixed(2)) + "</font>, "
                                        if(i==3) msg += "<br>"
                                    }
                                    return msg
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    DigiKeyFromLog.isAutoplay = false
                                    DigiKeyFromLog.currentLocationIndex = index
                                }
                            }
                        }

                        onCountChanged: {
                            positionViewAtEnd()
                        }
                    }

                    // Header: Ranging Engine
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: "#E6E9ED"

                        RowLayout {
                            anchors.fill: parent
                            
                            Text {
                                Layout.preferredWidth: 100
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                color: DigiKeyFromLog.isRanging ? "green" : "red"
                                font.pointSize: 10
                                text: "Ranging engine: " + (DigiKeyFromLog.isRanging ? "ON" : "OFF")
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Button {
                                text: DigiKeyFromLog.isRanging ? "Stop Ranging" : "Start Ranging"
                                palette {
                                    button: "white"
                                }
                                
                                onClicked: {
                                    DigiKeyFromLog.toggle_ranging()
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }

                    // Header: Read Log
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: "#E6E9ED"

                        RowLayout {
                            anchors.fill: parent
                            
                            Text {
                                Layout.preferredWidth: 100
                                height: parent.height
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 5
                                color: DigiKeyFromLog.isReadingLog ? "green" : "red"
                                font.pointSize: 10
                                text: "Log reader: " + (DigiKeyFromLog.isReadingLog ? "Reading" : "Paused")
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Button {
                                height: 30
                                text: DigiKeyFromLog.isReadingLog ? "Pause reading" : "Resume reading"
                                palette {
                                    button: "white"
                                }
                                
                                onClicked: {
                                    DigiKeyFromLog.toggle_reading_log()
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }
                    }
                } 
            }
        }
    }
}