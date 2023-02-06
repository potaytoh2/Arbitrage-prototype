require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomiclabs/hardhat-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers:[
      {version:"0.8.17"},
      {version: "0.6.6"},
      {version: "0.8.8"},
    ],
  },
  networks:{
    hardhat: {
      forking:{
        url: //Place url of node,
      },
    },
    testnet:{
      url: //Place url of node, 
      chainId: //place chainID of testNet, 
      accounts: //place private key; feel free to spin up an instance of hardhat network and use their private key,
    },
    mainnet:{
      url: //Place url of node,
      chainId: //place chainID of testNet,
      account: //[Enter private key here]
    }
  },
};
