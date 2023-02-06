# Project Name
> This projects mimics an arbitrage bot that swaps a tokenB for tokenC on Uniswap, then swaps tokenC for tokenB on SushiSwap. It is a test prototype that I'm using to make further improvements. 
## Table of Contents
* [General Info](#general-information)
* [Project Status](#project-status)
* [Limitations](#limitations)
<!-- * [License](#license) -->


## Setup
I used solidity >= 0.6.6 to write the smart contract. The codebase will require you to include the respective Tokens which you wish to swap. You can input this in the test.js and the smart contract: FlashSwap.sol . 

First you need to set up hardhat in your directory, run the following command:
``` 
npm install --save-dev hardhat
npm install --save-dev @nomicfoundation/hardhat-chai-matchers
```

Then create a hardhat project and just press ```enter``` all the way:
```
npx hardhat
```
Note if running the program doesn't work, you could try uninstalling this plugin:
```
npm uninstall @nomiclabs/hardhat-waffle ethereum-waffle
```
To deploy code:
```
npx hardhat run --network <your-network> scripts/deploy.js
```

## Project Status
Project is:  _ongoing_.

## limitations
As the project is ongoing, I have several improvements to make:
- Randmize and pick most liquid pairs for arbitrage 
- Define and increase number of trades between pairs for more arbitrage opportunities
- Implement a modified algorithm that can determine shortest path among X no. of different pairs for arbitrage
- Derive optimal input amount to maximise profit based on Uniswap's constant product market maker model  
- Factor gas output and transaction fees

