import QtQuick
import QtQuick.Layouts
import qs
import qs.services

Item {
  id: btn
  property string glyph: ""
  property string label: ""
  property bool dim: false
  property bool alert: false
  property bool lit: false
  property string popup: ""
  property bool active: popup !== "" && Ui.popup === popup
  signal clicked()
  signal middleClicked()
  signal scrolled(int direction)

  Layout.fillHeight: true
  Layout.preferredWidth: content.implicitWidth + 16

  Row {
    id: content
    anchors.centerIn: parent
    spacing: Theme.spaceSm
    Glyph {
      anchors.verticalCenter: parent.verticalCenter
      text: btn.glyph
      horizontalAlignment: Text.AlignLeft
      color: (area.containsMouse || btn.active) ? Theme.iconActive : btn.alert ? Theme.iconAlert : btn.lit ? Theme.iconActive : btn.dim ? Theme.iconDim : Theme.iconBody
      font.pixelSize: Theme.iconNormal
    }
    Label {
      anchors.verticalCenter: parent.verticalCenter
      visible: btn.label !== ""
      text: btn.label
      color: (area.containsMouse || btn.active) ? Theme.textSelected : btn.alert ? Theme.textError : btn.lit ? Theme.textSelected : btn.dim ? Theme.textHint : Theme.textBody
      font.pixelSize: Theme.fontBody
    }
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    onClicked: mouse => {
      if (mouse.button === Qt.MiddleButton) btn.middleClicked()
      else if (btn.popup !== "") Ui.togglePopup(btn.popup)
      else btn.clicked()
    }
    onWheel: wheel => btn.scrolled(wheel.angleDelta.y > 0 ? 1 : -1)
  }
}
