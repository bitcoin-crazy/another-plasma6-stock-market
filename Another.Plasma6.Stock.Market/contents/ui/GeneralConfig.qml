/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025-2026 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Stock Market was initially based on Another Plasma Coin 2.3.
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_enabled: enabledCheckBox.checked
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_textBold: boldTextCheck.checked
    property alias cfg_tickerName: textTickerField.text
    property alias cfg_showTickerName: showTickerNameCheckBox.checked
    property alias cfg_decimalPlaces: decimalPlacesSpinBox.value
    property alias cfg_priceMultiplier: priceMultiplierField.text
    property alias cfg_useThousandsSeparator: thousandsSeparatorCheckBox.checked
    property alias cfg_swapCommasDots: swapCommasDotsCheckBox.checked
    property alias cfg_textColor: textColorField.text
    property alias cfg_timeRefresh: timeRefreshSpinBox.value
    property alias cfg_blinkRefresh: blinkRefreshCheckBox.checked
    property alias cfg_apiKey: textAPIField.text
    property string cfg_tickerValue

    ScrollView {
        width: parent.width
        height: parent.height

        ColumnLayout {
            Layout.preferredWidth: parent.width - Kirigami.Units.largeSpacing * 2
            Layout.minimumWidth: preferredWidth
            Layout.maximumWidth: preferredWidth
            spacing: Kirigami.Units.smallSpacing * 3

            GridLayout {
                Layout.preferredWidth: parent.width
                Layout.minimumWidth: preferredWidth
                Layout.maximumWidth: preferredWidth
                columns: 2

                // Enabled
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Enabled:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: enabledCheckBox
                    onCheckedChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Enable or disable the applet. If disabled, a \"X\" will be displayed.")
                }

                // Font size
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Font Size for Price:")
                    horizontalAlignment: Label.AlignRight
                }
                SpinBox {
                    from: 5
                    id: fontSizeSpinBox
                    to: 40
                }

                // Bold text
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Bold:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: boldTextCheck
                }

                // Ticker
                Item {
                    Layout.minimumWidth: root.width / 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill: parent
                        spacing: 2

                        Label {
                            text: i18n("Ticker:")
                            horizontalAlignment: Label.AlignRight
                            verticalAlignment: Label.AlignVCenter
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.fillWidth: true
                        }
                    }
                }
                TextField {
                    id: textTickerField
                    validator: RegularExpressionValidator { regularExpression: /^[A-Za-z0-9]{0,6}(\.[A-Za-z0-9]{0,3})?$/ }
                    onTextChanged: {
                        if (text !== text.toUpperCase())
                            text = text.toUpperCase();
                        configurationChanged();
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("USA Stock Market Ticker, like MSTR, AAPL, AMZN, GE, SPY, or BRK.B. Only letters, numbers and one dot are allowed.")
                }

                // Ticker Value
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Ticker Value:")
                    horizontalAlignment: Label.AlignRight
                }
                ComboBox {
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        { text: i18n("Current Price"), value: "current_price" },
                        { text: i18n("Daily Price Change (%)"), value: "daily_price_change_percentage" }
                    ]
                    currentIndex: Math.max(0, indexOfValue(configRoot.cfg_tickerValue))
                    onActivated: {
                        configRoot.cfg_tickerValue = currentValue;
                        configurationChanged();
                    }
                }

                // Show Ticker Name
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Show Ticker Name")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: showTickerNameCheckBox
                }

                // Decimal Places
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Decimal Places:")
                    horizontalAlignment: Label.AlignRight
                }
                SpinBox {
                    id: decimalPlacesSpinBox
                    from: 0
                    to: 10
                    stepSize: 1
                    onValueChanged: configurationChanged()
                }

                // Price Multiplier with tooltip
                Item {
                    Layout.minimumWidth: root.width / 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill: parent
                        spacing: 2

                        Label {
                            text: i18n("Price Multiplier:")
                            horizontalAlignment: Label.AlignRight
                            verticalAlignment: Label.AlignVCenter
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.fillWidth: true
                        }
                    }
                }

                TextField {
                    id: priceMultiplierField
                    validator: RegularExpressionValidator { regularExpression: /^[0-9]*\.?[0-9]{0,4}$/ } // Max 4 decimal places
                    onTextChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Multiply the price by this value. Use only numbers (e.g., 1.3812). Max 4 decimal places. Default: 1. An asterisk will be placed next to the ticker name to symbolize the use of this feature. See the README at https://github.com/bitcoin-crazy/another-plasma6-stock-market for details.")
                }

                // Thousands Separator
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Thousands Separator:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: thousandsSeparatorCheckBox
                    onCheckedChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Format numbers with a thousands separator (e.g., 1,000.23).")
                }

                // Swap commas-dots
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Swap commas-dots:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: swapCommasDotsCheckBox
                    onCheckedChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Swap commas for dots and vice-versa to match usage in each country.")
                }

                // Text Color
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Text Color:")
                    horizontalAlignment: Label.AlignRight
                }
                TextField {
                    id: textColorField
                    onTextChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Use color names (red, yellowgreen) or HEX code (#ffff00 for yellow). Leave empty to use the theme's default color. Tips in README at https://github.com/bitcoin-crazy/another-plasma6-stock-market")
                }

                // Time Refresh
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Time Refresh (minutes):")
                    horizontalAlignment: Label.AlignRight
                }
                SpinBox {
                    id: timeRefreshSpinBox
                    from: 1
                    to: 60
                    stepSize: 1
                    onValueChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Minutes to refresh the price. Valid range: 1–60.")
                }

                // Blink Refresh
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("Blink Refresh:")
                    horizontalAlignment: Label.AlignRight
                }
                CheckBox {
                    id: blinkRefreshCheckBox
                    onCheckedChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Blink the price when it refreshes.")
                }

                // API key
                Item {
                    Layout.minimumWidth: root.width / 2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill: parent
                        spacing: 2

                        Label {
                            text: i18n("API key:")
                            horizontalAlignment: Label.AlignRight
                            verticalAlignment: Label.AlignVCenter
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            Layout.fillWidth: true
                        }
                    }
                }
                TextField {
                    id: textAPIField
                    onTextChanged: configurationChanged()
                    ToolTip.visible: hovered
                    ToolTip.text: i18n("Using an API key is mandatory. Get a free API key at https://finnhub.io/")
                }

                // Applet version
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("AP6 Stock Market, version:")
                    horizontalAlignment: Label.AlignRight
                }

                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("1.0    (2025-05-08)")
                }

                // Website
                Label {
                    Layout.minimumWidth: root.width / 2
                    text: i18n("AP6 Stock Market, website:")
                    horizontalAlignment: Label.AlignRight
                }

                Label {
                    Layout.minimumWidth: root.width / 2
                    text: "https://github.com/bitcoin-crazy/"
                }

            }  // Closing GridLayout
        }      // Closing ColumnLayout
    }          // Closing ScrollView
}              // Closing Item
