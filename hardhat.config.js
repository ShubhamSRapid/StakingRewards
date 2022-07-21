require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
const { mnemonic } = require('./secrets.json');

module.exports = {
// defaultNetwork: "ropsten",
  networks: {
    dev: {
      url: "https://babel-api.testnet.iotex.io",
      accounts: ['6523efad680162db51ada4436f1b2fc7d58908248dfe39214f55e9c523047664'],
      chainId: 4690,
      gas: 8500000,
      gasPrice: 1000000000000
    },
    ropsten: {
        url: `https://ropsten.infura.io/v3/230e20ccc00e4a94a67fd16a798de136`,
        chainId: 3,
        accounts: ['6523efad680162db51ada4436f1b2fc7d58908248dfe39214f55e9c523047664'],
        live: true,
        saveDeployments: false,
        tags: ["ropsten"],
        gasPrice: 5000000000,
        gas: 8000000,
    },
  },
  solidity:{
    compilers: [{
            version: "0.6.12",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200,
                },
            },
        },
        {
            version: "0.8.2",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 999999,
                },
            },
        },
        {
            version: "0.8.7",
            settings: {
                optimizer: {
                    enabled: true,
                    runs: 200,
                },
            },
        },
    ],
},
};