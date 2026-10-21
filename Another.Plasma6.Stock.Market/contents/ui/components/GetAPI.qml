/*
 * SPDX-FileCopyrightText: Copyright 2025 zayronxio
 * SPDX-FileCopyrightText: Copyright 2025-2026 bitcoin-crazy
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-SnippetComment: Another Plasma6 Stock Market was initially based on Another Plasma Coin 2.3.
 * SPDX-SnippetComment: Another Plasma6 Coin was initially based on Plasma Coin 1.0.2, from zayronxio.
 */
import QtQuick
import org.kde.plasma.plasmoid

Item {
    property string tickerName: ""
    property string apiKey: ""
    property var price: null                        // number, or null when unknown/error
    property var dailyPriceChangePercentage: null   // number, or null when unknown/error
    property bool inErrorState: false

    property int requestId: 0                       // only the latest request may update the data

    // Ticker or API key changed: wait a little, so typing does not fire one request per key
    onTickerNameChanged: debounce.restart()
    onApiKeyChanged: debounce.restart()

    function setError(retryLater) {
        price = null;
        dailyPriceChangePercentage = null;
        inErrorState = true;
        if (retryLater)
            retry.start();
    }

    function updatePrice() {
        if (!tickerName)
            return;

        if (!apiKey) {
            setError(false);
            return;
        }

        const id = ++requestId;
        const url = "https://finnhub.io/api/v1/quote?symbol=" + encodeURIComponent(tickerName)
                  + "&token=" + encodeURIComponent(apiKey);

        const req = new XMLHttpRequest();
        req.open("GET", url, true);
        req.timeout = 15000;

        req.onreadystatechange = function () {
            if (req.readyState !== 4 || id !== requestId)
                return;

            if (req.status !== 200) {
                console.error(`Ap6SM: Query failed with status: ${req.status}`);
                setError(true);
                return;
            }

            try {
                const data = JSON.parse(req.responseText);
                // Invalid tickers come as c = 0 and dp = null. A daily change of 0 is valid.
                if (data && typeof data.c === "number" && data.c > 0 && typeof data.dp === "number") {
                    price = data.c;
                    dailyPriceChangePercentage = data.dp;
                    inErrorState = false;
                    retry.stop();
                } else {
                    setError(false);
                }
            } catch (e) {
                console.error("Ap6SM: Error parsing API response:", e);
                setError(true);
            }
        };

        req.send();
    }

    Timer {
        id: debounce
        interval: 500
        repeat: false
        onTriggered: updatePrice()
    }

    Timer {
        id: retry
        interval: 60000 // Retry after 60 seconds
        repeat: false
        onTriggered: updatePrice()
    }
}
