import QtQuick

ListModel {
    readonly property var data: [
        {
            id:"bitcoin",
            symbol:"btc",
            name:"Bitcoin",
            image:"https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400",
            currentPrice:82611,
            marketCap:1640130757306,
            totalVolume:45229801768,
            priceChangePercentage24h:1.12796
        },
        {
            id:"ethereum",
            symbol:"eth",
            name:"Ethereum",
            image:"https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628",
            currentPrice:1566.33,
            marketCap:189055410702,
            totalVolume:20711107810,
            priceChangePercentage24h:-1.64949
        },
        {
            id:"tether",
            symbol:"usdt",
            name:"Tether",
            image:"https://coin-images.coingecko.com/coins/images/325/large/Tether.png?1696501661",
            currentPrice:0.99945,
            marketCap:144262835047,
            totalVolume:63740037911,
            priceChangePercentage24h:0.00563
        },
        {
            id:"ripple",
            symbol:"xrp",
            name:"XRP",
            image:"https://coin-images.coingecko.com/coins/images/44/large/xrp-symbol-white-128.png?1696501442",
            currentPrice:2.02,
            marketCap:117508455731,
            totalVolume:3596184315,
            priceChangePercentage24h:0.77343
        },
        {
            id:"binancecoin",
            symbol:"bnb",
            name:"BNB",
            image:"https://coin-images.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1696501970",
            currentPrice:584.27,
            marketCap:85234300118,
            totalVolume:888760043,
            priceChangePercentage24h:1.23203
        },
        {
            id:"solana",
            symbol:"sol",
            name:"Solana",
            image:"https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756",
            currentPrice:118.62,
            marketCap:61188598899,
            totalVolume:4770350518,
            priceChangePercentage24h:3.86731
        },
        {
            id:"usd-coin",
            symbol:"usdc",
            name:"USDC",
            image:"https://coin-images.coingecko.com/coins/images/6319/large/usdc.png?1696506694",
            currentPrice:0.999989,
            marketCap:59969972381,
            totalVolume:12556163131,
            priceChangePercentage24h:0.00042
        },
        {
            id:"dogecoin",
            symbol:"doge",
            name:"Dogecoin",
            image:"https://coin-images.coingecko.com/coins/images/5/large/dogecoin.png?1696501409",
            currentPrice:0.158562,
            marketCap:23607335479,
            totalVolume:1138482228,
            priceChangePercentage24h:1.7644
        },
        {
            id:"cardano",
            symbol:"ada",
            name:"Cardano",
            image:"https://coin-images.coingecko.com/coins/images/975/large/cardano.png?1696502090",
            currentPrice:0.631915,
            marketCap:22777860980,
            totalVolume:923296913,
            priceChangePercentage24h:1.50133
        },
        {
            id:"tron",
            symbol:"trx",
            name:"TRON",
            image:"https://coin-images.coingecko.com/coins/images/1094/large/tron-logo.png?1696502193",
            currentPrice:0.237535,
            marketCap:22595363929,
            totalVolume:743698714,
            priceChangePercentage24h:-1.64857
        },
        {
            id:"staked-ether",
            symbol:"steth",
            name:"Lido Staked Ether",
            image:"https://coin-images.coingecko.com/coins/images/13442/large/steth_logo.png?1696513206",
            currentPrice:1564.98,
            marketCap:14708927755,
            totalVolume:49704349,
            priceChangePercentage24h:-1.5212
        },
        {
            id:"wrapped-bitcoin",
            symbol:"wbtc",
            name:"Wrapped Bitcoin",
            image:"https://coin-images.coingecko.com/coins/images/7598/large/wrapped_bitcoin_wbtc.png?1696507857",
            currentPrice:82611,
            marketCap:10652145813,
            totalVolume:402968062,
            priceChangePercentage24h:1.18475
        },
        {
            id:"leo-token",
            symbol:"leo",
            name:"LEO Token",
            image:"https://coin-images.coingecko.com/coins/images/8418/large/leo-token.png?1696508607",
            currentPrice:9.43,
            marketCap:8714827103,
            totalVolume:3259705,
            priceChangePercentage24h:0.26011
        },
        {
            id:"chainlink",
            symbol:"link",
            name:"Chainlink",
            image:"https://coin-images.coingecko.com/coins/images/877/large/chainlink-new-logo.png?1696502009",
            currentPrice:12.59,
            marketCap:8035693786,
            totalVolume:518542999,
            priceChangePercentage24h:1.93063
        },
        {
            id:"avalanche-2",
            symbol:"avax",
            name:"Avalanche",
            image:"https://coin-images.coingecko.com/coins/images/12559/large/Avalanche_Circle_RedWhite_Trans.png?1696512369",
            currentPrice:18.86,
            marketCap:7841786540,
            totalVolume:325123363,
            priceChangePercentage24h:5.00977
        },
        {
            id:"usds",
            symbol:"usds",
            name:"USDS",
            image:"https://coin-images.coingecko.com/coins/images/39926/large/usds.webp?1726666683",
            currentPrice:0.99998,
            marketCap:7489321319,
            totalVolume:12325468,
            priceChangePercentage24h:0.02509
        },
        {
            id:"hedera-hashgraph",
            symbol:"hbar",
            name:"Hedera",
            image:"https://coin-images.coingecko.com/coins/images/3688/large/hbar.png?1696504364",
            currentPrice:0.173553,
            marketCap:7329558455,
            totalVolume:412015130,
            priceChangePercentage24h:2.05681
        },
        {
            id:"stellar",
            symbol:"xlm",
            name:"Stellar",
            image:"https://coin-images.coingecko.com/coins/images/100/large/fmpFRHHQ_400x400.jpg?1735231350",
            currentPrice:0.236356,
            marketCap:7276702220,
            totalVolume:185335102,
            priceChangePercentage24h:1.05844
        },
        {
            id:"the-open-network",
            symbol:"ton",
            name:"Toncoin",
            image:"https://coin-images.coingecko.com/coins/images/17980/large/photo_2024-09-10_17.09.00.jpeg?1725963446",
            currentPrice:2.92,
            marketCap:7247619200,
            totalVolume:203321939,
            priceChangePercentage24h:-2.18034
        },
        {
            id:"sui",
            symbol:"sui",
            name:"Sui",
            image:"https://coin-images.coingecko.com/coins/images/26375/large/sui-ocean-square.png?1727791290",
            currentPrice:2.19,
            marketCap:7123792624,
            totalVolume:891630485,
            priceChangePercentage24h:2.65015
        },
        {
            id:"shiba-inu",
            symbol:"shib",
            name:"Shiba Inu",
            image:"https://coin-images.coingecko.com/coins/images/11939/large/shiba.png?1696511800",
            currentPrice:0.000012,
            marketCap:7074845605,
            totalVolume:191065012,
            priceChangePercentage24h:0.4039
        },
        {
            id:"wrapped-steth",
            symbol:"wsteth",
            name:"Wrapped stETH",
            image:"https://coin-images.coingecko.com/coins/images/18834/large/wstETH.png?1696518295",
            currentPrice:1876.02,
            marketCap:6728523483,
            totalVolume:26245637,
            priceChangePercentage24h:-1.75165
        },
        {
            id:"mantra-dao",
            symbol:"om",
            name:"MANTRA",
            image:"https://coin-images.coingecko.com/coins/images/12151/large/OM_Token.png?1696511991",
            currentPrice:6.45,
            marketCap:6216039326,
            totalVolume:134881371,
            priceChangePercentage24h:-4.16201
        },
        {
            id:"bitcoin-cash",
            symbol:"bch",
            name:"Bitcoin Cash",
            image:"https://coin-images.coingecko.com/coins/images/780/large/bitcoin-cash-circle.png?1696501932",
            currentPrice:304.5,
            marketCap:6044303288,
            totalVolume:143948820,
            priceChangePercentage24h:3.63271
        },
        {
            id:"litecoin",
            symbol:"ltc",
            name:"Litecoin",
            image:"https://coin-images.coingecko.com/coins/images/2/large/litecoin.png?1696501400",
            currentPrice:77.04,
            marketCap:5840509957,
            totalVolume:390550771,
            priceChangePercentage24h:4.79062
        },
        {
            id:"polkadot",
            symbol:"dot",
            name:"Polkadot",
            image:"https://coin-images.coingecko.com/coins/images/12171/large/polkadot.png?1696512008",
            currentPrice:3.53,
            marketCap:5376329223,
            totalVolume:193586555,
            priceChangePercentage24h:1.52782
        },
        {
            id:"binance-bridged-usdt-bnb-smart-chain",
            symbol:"bsc-usd",
            name:"Binance Bridged USDT (BNB Smart Chain)",
            image:"https://coin-images.coingecko.com/coins/images/35021/large/USDT.png?1707233575",
            currentPrice:0.999602,
            marketCap:5182312500,
            totalVolume:237550900,
            priceChangePercentage24h:0.18813
        },
        {
            id:"bitget-token",
            symbol:"bgb",
            name:"Bitget Token",
            image:"https://coin-images.coingecko.com/coins/images/11610/large/Bitget_logo.png?1736925727",
            currentPrice:4.27,
            marketCap:5118644858,
            totalVolume:217903745,
            priceChangePercentage24h:-0.23151
        },
        {
            id:"hyperliquid",
            symbol:"hype",
            name:"Hyperliquid",
            image:"https://coin-images.coingecko.com/coins/images/50882/large/hyperliquid.jpg?1729431300",
            currentPrice:15.14,
            marketCap:5099169762,
            totalVolume:170854876,
            priceChangePercentage24h:6.21348
        },
        {
            id:"ethena-usde",
            symbol:"usde",
            name:"Ethena USDe",
            image:"https://coin-images.coingecko.com/coins/images/33613/large/usde.png?1733810059",
            currentPrice:0.998887,
            marketCap:5037202927,
            totalVolume:65541514,
            priceChangePercentage24h:0.03877
        },
        {
            id:"weth",
            symbol:"weth",
            name:"WETH",
            image:"https://coin-images.coingecko.com/coins/images/2518/large/weth.png?1696503332",
            currentPrice:1565.16,
            marketCap:4284755299,
            totalVolume:319501469,
            priceChangePercentage24h:-1.76278
        },
        {
            id:"pi-network",
            symbol:"pi",
            name:"Pi Network",
            image:"https://coin-images.coingecko.com/coins/images/54342/large/pi_network.jpg?1739347576",
            currentPrice:0.607318,
            marketCap:4178197426,
            totalVolume:169099038,
            priceChangePercentage24h:2.32957
        },
        {
            id:"whitebit",
            symbol:"wbt",
            name:"WhiteBIT Coin",
            image:"https://coin-images.coingecko.com/coins/images/27045/large/wbt_token.png?1696526096",
            currentPrice:27.95,
            marketCap:4021944323,
            totalVolume:45806127,
            priceChangePercentage24h:0.05469
        },
        {
            id:"monero",
            symbol:"xmr",
            name:"Monero",
            image:"https://coin-images.coingecko.com/coins/images/69/large/monero_logo.png?1696501460",
            currentPrice:202.57,
            marketCap:3734958907,
            totalVolume:49628855,
            priceChangePercentage24h:-1.09761
        },
        {
            id:"wrapped-eeth",
            symbol:"weeth",
            name:"Wrapped eETH",
            image:"https://coin-images.coingecko.com/coins/images/33033/large/weETH.png?1701438396",
            currentPrice:1665.62,
            marketCap:3494198601,
            totalVolume:8707618,
            priceChangePercentage24h:-1.73699
        },
        {
            id:"okb",
            symbol:"okb",
            name:"OKB",
            image:"https://coin-images.coingecko.com/coins/images/4463/large/WeChat_Image_20220118095654.png?1696505053",
            currentPrice:53.23,
            marketCap:3194476005,
            totalVolume:18587753,
            priceChangePercentage24h:-0.06711
        },
        {
            id:"dai",
            symbol:"dai",
            name:"Dai",
            image:"https://coin-images.coingecko.com/coins/images/9956/large/Badge_Dai.png?1696509996",
            currentPrice:1,
            marketCap:3123164967,
            totalVolume:183253116,
            priceChangePercentage24h:0.06852
        },
        {
            id:"uniswap",
            symbol:"uni",
            name:"Uniswap",
            image:"https://coin-images.coingecko.com/coins/images/12504/large/uniswap-logo.png?1720676669",
            currentPrice:5.19,
            marketCap:3119806246,
            totalVolume:151926055,
            priceChangePercentage24h:0.47858
        },
        {
            id:"susds",
            symbol:"susds",
            name:"sUSDS",
            image:"https://coin-images.coingecko.com/coins/images/52721/large/sUSDS_Coin.png?1734086971",
            currentPrice:1.047,
            marketCap:2995097616,
            totalVolume:9750538,
            priceChangePercentage24h:0.03373
        },
        {
            id:"coinbase-wrapped-btc",
            symbol:"cbbtc",
            name:"Coinbase Wrapped BTC",
            image:"https://coin-images.coingecko.com/coins/images/40143/large/cbbtc.webp?1726136727",
            currentPrice:82702,
            marketCap:2922160895,
            totalVolume:333910197,
            priceChangePercentage24h:1.25559
        },
        {
            id:"pepe",
            symbol:"pepe",
            name:"Pepe",
            image:"https://coin-images.coingecko.com/coins/images/29850/large/pepe-token.jpeg?1696528776",
            currentPrice:0.00000688,
            marketCap:2897181018,
            totalVolume:620072921,
            priceChangePercentage24h:2.4761
        },
        {
            id:"aptos",
            symbol:"apt",
            name:"Aptos",
            image:"https://coin-images.coingecko.com/coins/images/26455/large/aptos_round.png?1696525528",
            currentPrice:4.77,
            marketCap:2885676568,
            totalVolume:126824600,
            priceChangePercentage24h:4.812
        }
    ]

    Component.onCompleted: {
        for (let i = 0; i < 5; i++) {
            append(data)
        }
    }
}
