/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Stock Market was initially based on Another Plasma Coin 2.3.
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */
import QtQuick

Item {
    property string tickerName: ""
    property string apiKey: ""
    property int decimalPlaces: 2
    property int refreshRate: Plasmoid.configuration.timeRefresh || 3 // Refresh rate in minutes, linked to config
    property var price: null // Set no initial price
    property bool inErrorState: false

    onTickerNameChanged: updatePrice()
    onApiKeyChanged: updatePrice()

    function updatePrice() {
        if (!tickerName || tickerName === "")
            return;

        const url = "https://finnhub.io/api/v1/quote?symbol=" + tickerName + "&token=" + apiKey;
        updateAPI(url);
    }

    function updateAPI(url) {
        const req = new XMLHttpRequest();
        req.open("GET", url, true);

        req.onreadystatechange = function () {
            if (req.readyState !== 4) return;

            if (req.status === 200) {
                try {
                    const data = JSON.parse(req.responseText);
                    if (data && data.c) {
                        price = parseFloat(data.c); // Parse and store the price
                        inErrorState = false;
                    } else {
                        // If no valid price data, set as error state
                        price = "E";
                        inErrorState = true;
                    }
                } catch (e) {
                    console.error("Ap6SM: Error parsing API response:", e);
                    price = "E"; // Use 'E' to indicate error
                    inErrorState = true;
                    retry.start(); // Retry if parsing fails
                }
            } else {
                console.error(`Ap6SM: Query failed with status: ${req.status}`);
                price = "E"; // Use 'E' to indicate HTTP error
                inErrorState = true;
                retry.start(); // Retry on error
            }
        };

        req.send();
    }

    Timer {
        id: retry
        interval: 60000 // Retry after 60 seconds
        repeat: false
        running: false
        onTriggered: updatePrice()
    }

    Timer {
        id: updateTimer
        interval: refreshRate * 60000 // Convert from minutes to milliseconds
        repeat: true
        running: true
        onTriggered: updatePrice()
    }

    Component.onCompleted: updatePrice()
}
