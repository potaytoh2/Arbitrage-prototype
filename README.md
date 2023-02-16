# Project Name
> This projects mimics an arbitrage bot that leverages on flashloans to swap a tokenB for tokenC on Uniswap, then swaps tokenC for tokenB on SushiSwap. It is a test prototype that I'm using to make further improvements.

## Table of Contents
* [Set up](#setup)
* [Project Status](#project-status)
* [Limitations](#limitations)
<!-- * [License](#license) -->

## Setup
I used solidity >= 0.6.6 to write the smart contract. The codebase will require you to include the respective Tokens which you wish to swap. You can input these token addresses in the test.js and the smart contract: FlashSwap.sol 

You will also need to include a whale's address for tokenB. Hardhat will impersonate that address and use its funds to send tokens to the contract. The amount of which needs to be specified by you.

Lastly, fill up the config.js file (as indicated by the comments)  

First, install through: 
```
git clone https://github.com/potaytoh2/Arbitrage-prototype 
npm install
```
To deploy code:
```
npx hardhat run --network <your-network> scripts/deploy.js
```

## Project Status
Project is:  _ongoing_.

## limitations
As the project is ongoing, I have several improvements to make:
- Randomize and pick most liquid pairs for arbitrage 
- Define and increase number of trades between pairs for more arbitrage opportunities
- Implement a modified algorithm that can determine shortest path among X no. of different pairs for arbitrage
- Derive optimal input amount to maximise profit based on Uniswap's constant product market maker model  
- Factor gas output and transaction fees

