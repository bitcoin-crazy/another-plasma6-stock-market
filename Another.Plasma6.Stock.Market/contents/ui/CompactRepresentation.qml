/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025-2026 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Stock Market was initially based on Another Plasma Coin 2.3.
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import "components" as Components

ColumnLayout {
    id: wrapper

    property int pixelFontVar: Plasmoid.configuration.fontSize
    property int pixelFontVar2: pixelFontVar * 0.7
    property int heightroot: 20

    // Price multiplier as a number (empty or invalid values count as 1)
    readonly property real multiplier: {
        const m = parseFloat(Plasmoid.configuration.priceMultiplier);
        return isNaN(m) ? 1 : m;
    }

    // User color, or the theme color if empty
    readonly property var baseTextColor: Plasmoid.configuration.textColor || Kirigami.Theme.textColor

    spacing: 0
    Layout.minimumWidth: tickerText.implicitWidth + pixelFontVar * 4
    Layout.minimumHeight: heightroot

    // Formats a number with the configured decimal places and separators
    function formatNumber(num) {
        const swap = Plasmoid.configuration.swapCommasDots;
        const parts = num.toFixed(Plasmoid.configuration.decimalPlaces).split(".");

        // Thousands separator only in the integer part
        if (Plasmoid.configuration.useThousandsSeparator)
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, swap ? "." : ",");

        return parts.join(swap ? "," : ".");
    }

    function formatPriceChange(num) {
        return (num >= 0 ? "+" : "") + formatNumber(num) + "%";
    }

    Components.GetAPI {
        id: getApi
        tickerName: Plasmoid.configuration.tickerName
        apiKey: Plasmoid.configuration.apiKey
    }

    // Text shown in the toolbar, with the multiplier applied
    property string displayedPrice: {
        if (getApi.inErrorState)
            return "Err";

        switch (Plasmoid.configuration.tickerValue) {
            case "daily_price_change_percentage":
                if (getApi.dailyPriceChangePercentage === null)
                    return "?";
                return formatPriceChange(getApi.dailyPriceChangePercentage);
            case "current_price":
                if (getApi.price === null)
                    return "?";
                return formatNumber(getApi.price * multiplier);
            default:
                return "Err";
        }
    }

    Text {
        id: tickerText
        visible: Plasmoid.configuration.showTickerName
        width: wrapper.width
        font.pixelSize: pixelFontVar2
        color: getApi.inErrorState ? Kirigami.Theme.negativeTextColor : baseTextColor
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: (Plasmoid.configuration.tickerName || "Unknown ticker") + (multiplier !== 1 ? "*" : "")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
    }

    Text {
        id: priceText
        width: wrapper.width
        font.pixelSize: pixelFontVar
        color: {
            if (getApi.inErrorState)
                return Kirigami.Theme.negativeTextColor;
            if (Plasmoid.configuration.tickerValue === "daily_price_change_percentage") {
                if (getApi.dailyPriceChangePercentage > 0)
                    return Kirigami.Theme.positiveTextColor;
                if (getApi.dailyPriceChangePercentage < 0)
                    return Kirigami.Theme.negativeTextColor;
            }
            return baseTextColor;
        }
        font.bold: Plasmoid.configuration.textBold
        font.capitalization: Font.AllUppercase
        text: displayedPrice
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        height: 30
    }

    MouseArea {
        anchors.fill: priceText
        onClicked: {
            getApi.updatePrice(); // Update price when clicking
            fadeAnimation.start();
        }
    }

    SequentialAnimation {
        id: fadeAnimation
        PropertyAnimation { target: priceText; property: "opacity"; to: 0.0; duration: 500 }
        PropertyAnimation { target: priceText; property: "opacity"; to: 1.0; duration: 500 }
    }

    Timer {
        interval: (Plasmoid.configuration.timeRefresh || 3) * 60000 // Minutes to milliseconds
        repeat: true
        running: true
        onTriggered: {
            getApi.updatePrice();
            if (Plasmoid.configuration.blinkRefresh)
                fadeAnimation.start();
        }
    }
}
