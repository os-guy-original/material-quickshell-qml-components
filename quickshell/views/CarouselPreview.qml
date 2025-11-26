import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects
import "../resources/components" as Components
import "../resources/components/layout" as LayoutComponents
import "../resources/components/actions" as Actions
import "../resources/components/navigation" as Navigation

Window {
    id: window
    visible: true
    width: 1200
    height: 900
    title: "Carousel Component Preview"
    color: Components.ColorPalette.background
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Top App Bar
        Navigation.TopAppBar {
            Layout.fillWidth: true
            title: "Carousel Component"
            backgroundColor: Components.ColorPalette.surface
            
            Actions.SegmentedControl {
                options: ["Hero", "Multi-browse", "Uncontained"]
                currentIndex: layoutStack.currentIndex
                onChanged: (index) => layoutStack.currentIndex = index
            }
        }
        
        // Divider
        LayoutComponents.Divider {
            Layout.fillWidth: true
        }
        
        // Main content
        LayoutComponents.Container {
            Layout.fillWidth: true
            Layout.fillHeight: true
            fillParent: false
            outerMargin: 0
            padding: 32
            backgroundColor: Components.ColorPalette.background
            
            ColumnLayout {
                width: parent.width
                spacing: 24
                
                // Layout stack
                StackLayout {
                    id: layoutStack
                    Layout.fillWidth: true
                    currentIndex: 0
                    
                    // Hero Layout
                    ColumnLayout {
                        spacing: 24
                        
                        ColumnLayout {
                            spacing: 8
                            
                            Text {
                                text: "Hero Layout"
                                color: Components.ColorPalette.onSurface
                                font.pixelSize: 24
                                font.bold: true
                            }
                            
                            Text {
                                text: "Large center item with small side items. Perfect for featured content."
                                color: Components.ColorPalette.onSurfaceVariant
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                        
                        // Center Hero
                        LayoutComponents.Card {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 400
                            padding: 20
                            
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16
                                
                                RowLayout {
                                    spacing: 12
                                    
                                    Text {
                                        text: "Center Hero"
                                        color: Components.ColorPalette.onSurface
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                    
                                    Rectangle {
                                        Layout.preferredWidth: codeLabel1.width + 16
                                        Layout.preferredHeight: 26
                                        color: Components.ColorPalette.surfaceVariant
                                        radius: 6
                                        
                                        Text {
                                            id: codeLabel1
                                            anchors.centerIn: parent
                                            text: "flexWeights: [1, 7, 1]"
                                            color: Components.ColorPalette.primary
                                            font.pixelSize: 12
                                            font.family: "monospace"
                                        }
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                }
                                
                                LayoutComponents.Carousel {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    flexWeights: [1, 7, 1]
                                    itemSpacing: 12
                                    itemRadius: 20
                                    
                                    model: heroModel
                                    delegate: heroDelegate
                                }
                            }
                        }
                        
                        // Left Hero
                        LayoutComponents.Card {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 320
                            padding: 20
                            
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16
                                
                                RowLayout {
                                    spacing: 12
                                    
                                    Text {
                                        text: "Left Hero"
                                        color: Components.ColorPalette.onSurface
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                    
                                    Rectangle {
                                        Layout.preferredWidth: codeLabel2.width + 16
                                        Layout.preferredHeight: 26
                                        color: Components.ColorPalette.surfaceVariant
                                        radius: 6
                                        
                                        Text {
                                            id: codeLabel2
                                            anchors.centerIn: parent
                                            text: "flexWeights: [7, 2]"
                                            color: Components.ColorPalette.primary
                                            font.pixelSize: 12
                                            font.family: "monospace"
                                        }
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                }
                                
                                LayoutComponents.Carousel {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    flexWeights: [7, 2]
                                    itemSpacing: 12
                                    itemRadius: 20
                                    
                                    model: heroModel
                                    delegate: heroDelegate
                                }
                            }
                        }
                    }
                    
                    // Multi-browse Layout
                    ColumnLayout {
                        spacing: 24
                        
                        ColumnLayout {
                            spacing: 8
                            
                            Text {
                                text: "Multi-browse Layout"
                                color: Components.ColorPalette.onSurface
                                font.pixelSize: 24
                                font.bold: true
                            }
                            
                            Text {
                                text: "Multiple items visible with varying sizes. Great for browsing collections."
                                color: Components.ColorPalette.onSurfaceVariant
                                font.pixelSize: 14
                            }
                        }
                        
                        LayoutComponents.Card {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 300
                            padding: 20
                            
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16
                                
                                RowLayout {
                                    spacing: 12
                                    
                                    Text {
                                        text: "5-item Pattern"
                                        color: Components.ColorPalette.onSurface
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                    
                                    Rectangle {
                                        Layout.preferredWidth: codeLabel3.width + 16
                                        Layout.preferredHeight: 26
                                        color: Components.ColorPalette.surfaceVariant
                                        radius: 6
                                        
                                        Text {
                                            id: codeLabel3
                                            anchors.centerIn: parent
                                            text: "flexWeights: [1, 2, 3, 2, 1]"
                                            color: Components.ColorPalette.primary
                                            font.pixelSize: 12
                                            font.family: "monospace"
                                        }
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                }
                                
                                LayoutComponents.Carousel {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    flexWeights: [1, 2, 3, 2, 1]
                                    itemSpacing: 10
                                    itemRadius: 16
                                    
                                    model: categoryModel
                                    delegate: categoryDelegate
                                }
                            }
                        }
                    }
                    
                    // Uncontained Layout
                    ColumnLayout {
                        spacing: 24
                        
                        ColumnLayout {
                            spacing: 8
                            
                            Text {
                                text: "Uncontained Layout"
                                color: Components.ColorPalette.onSurface
                                font.pixelSize: 24
                                font.bold: true
                            }
                            
                            Text {
                                text: "Fixed-size items that scroll edge-to-edge. Classic carousel behavior."
                                color: Components.ColorPalette.onSurfaceVariant
                                font.pixelSize: 14
                            }
                        }
                        
                        LayoutComponents.Card {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 320
                            padding: 20
                            
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 16
                                
                                RowLayout {
                                    spacing: 12
                                    
                                    Text {
                                        text: "Fixed Width"
                                        color: Components.ColorPalette.onSurface
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                    
                                    Rectangle {
                                        Layout.preferredWidth: codeLabel4.width + 16
                                        Layout.preferredHeight: 26
                                        color: Components.ColorPalette.surfaceVariant
                                        radius: 6
                                        
                                        Text {
                                            id: codeLabel4
                                            anchors.centerIn: parent
                                            text: "itemExtent: 280"
                                            color: Components.ColorPalette.primary
                                            font.pixelSize: 12
                                            font.family: "monospace"
                                        }
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                }
                                
                                LayoutComponents.Carousel {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    itemExtent: 280
                                    itemSpacing: 16
                                    itemRadius: 20
                                    
                                    model: heroModel
                                    delegate: heroDelegate
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Data Models
    ListModel {
        id: heroModel
        ListElement { 
            title: "The Flow"
            subtitle: "Season 1 Now Streaming"
            color: "#2196F3"
            image: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&h=600&fit=crop"
        }
        ListElement { 
            title: "Through the Pane"
            subtitle: "Season 1 Now Streaming"
            color: "#9C27B0"
            image: "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&h=600&fit=crop"
        }
        ListElement { 
            title: "Iridescence"
            subtitle: "Season 1 Now Streaming"
            color: "#FF5722"
            image: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&h=600&fit=crop"
        }
        ListElement { 
            title: "Sea Change"
            subtitle: "Season 1 Now Streaming"
            color: "#00BCD4"
            image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800&h=600&fit=crop"
        }
        ListElement { 
            title: "Blue Symphony"
            subtitle: "Season 1 Now Streaming"
            color: "#3F51B5"
            image: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800&h=600&fit=crop"
        }
        ListElement { 
            title: "Golden Hour"
            subtitle: "Season 1 Now Streaming"
            color: "#FFC107"
            image: "https://images.unsplash.com/photo-1495616811223-4d98c6e9c869?w=800&h=600&fit=crop"
        }
        ListElement { 
            title: "Night Sky"
            subtitle: "Season 1 Now Streaming"
            color: "#607D8B"
            image: "https://images.unsplash.com/photo-1475274047050-1d0c0975c63e?w=800&h=600&fit=crop"
        }
        ListElement { 
            title: "Aurora"
            subtitle: "Season 1 Now Streaming"
            color: "#E91E63"
            image: "https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800&h=600&fit=crop"
        }
    }
    
    ListModel {
        id: categoryModel
        ListElement { title: "Action"; icon: "🎬"; color: "#E53935" }
        ListElement { title: "Comedy"; icon: "😂"; color: "#FB8C00" }
        ListElement { title: "Drama"; icon: "🎭"; color: "#8E24AA" }
        ListElement { title: "Sci-Fi"; icon: "🚀"; color: "#1E88E5" }
        ListElement { title: "Horror"; icon: "👻"; color: "#424242" }
        ListElement { title: "Romance"; icon: "💕"; color: "#EC407A" }
        ListElement { title: "Documentary"; icon: "📚"; color: "#43A047" }
        ListElement { title: "Animation"; icon: "✨"; color: "#00ACC1" }
    }
    
    // Delegates
    Component {
        id: heroDelegate
        
        Rectangle {
            id: heroCard
            property var modelData
            property int index
            
            color: modelData ? modelData.color : "#333"
            
            // Background image
            Image {
                anchors.fill: parent
                source: modelData ? modelData.image : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                
                // Loading placeholder
                Rectangle {
                    anchors.fill: parent
                    color: modelData ? modelData.color : "#333"
                    visible: parent.status !== Image.Ready
                    
                    Text {
                        anchors.centerIn: parent
                        text: parent.parent.status === Image.Loading ? "Loading..." : ""
                        color: "white"
                        font.pixelSize: 14
                        opacity: 0.7
                    }
                }
            }
            
            // Gradient overlay for text readability
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.4; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.75) }
                }
            }
            
            // Content
            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20
                spacing: 4
                
                Text {
                    text: modelData ? modelData.title : ""
                    color: "white"
                    font.pixelSize: 22
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    
                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 4
                        samples: 9
                        color: Qt.rgba(0, 0, 0, 0.5)
                    }
                }
                
                Text {
                    text: modelData ? modelData.subtitle : ""
                    color: Qt.rgba(1, 1, 1, 0.9)
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
    
    Component {
        id: categoryDelegate
        
        Rectangle {
            property var modelData
            property int index
            
            color: modelData ? modelData.color : "#333"
            radius: 16
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8
                
                Text {
                    text: modelData ? modelData.icon : ""
                    font.pixelSize: 32
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: modelData ? modelData.title : ""
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
