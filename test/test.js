const { expect,assert } = require("chai");
const { ethers } = require("hardhat");

const {impersonateFundErc20} = require("../utils/utilities");

const {abi} = require("../artifacts/contracts/interfaces/IERC20.sol/IERC20.json");

const provider = ethers.provider;

describe("FlashSwap Contract", () =>{
  
  let FLASHSWAP, BORROW_AMOUNT, FUND_AMOUNT, initialFundingHuman, txArbitrage, fasUsedUSD;
  const DECIMALS = 6;

  const tokenB_WHALE = //Place Whale's address here...
  
  //To swap Token B for Token C on Uniswap, then swaps Token C for Token B on SushiSwap
  const tokenB = //Place address of tokenB here;
  const tokenC = //Place address of tokenC here;
  
  const BASE_TOKEN_ADDRESS = tokenB;
  const tokenBase = new ethers.Contract(BASE_TOKEN_ADDRESS, abi, provider);

  beforeEach(async ()=>{
    [owner] = await ethers.getSigners();
    const whale_balance = await provider.getBalance(tokenB_WHALE);
    expect(whale_balance).not.equal("0");

    const FlashSwap = await ethers.getContractFactory("UniswapCrossFlash");
    FLASHSWAP = await FlashSwap.deploy();
    await FLASHSWAP.deployed();

    const borrowAmountHuman = "1"; 
    BORROW_AMOUNT = ethers.utils.parseUnits(borrowAmountHuman, DECIMALS);

    initialFundingHuman = "100";    
    FUND_AMOUNT = ethers.utils.parseUnits(borrowAmountHuman, DECIMALS);
    await impersonateFundErc20(tokenBase, tokenB_WHALE, FLASHSWAP.address, initialFundingHuman, DECIMALS);
  });

  describe("Arbitrage Execution", () =>{
    it("Contract is funded", async ()=> {
      const flashSwapBalance = await FLASHSWAP.getBalanceOfToken(BASE_TOKEN_ADDRESS);
      const flashSwapBalanceHuman = ethers.utils.formatUnits(flashSwapBalance, DECIMALS);
      console.log(flashSwapBalanceHuman);
      expect(Number(flashSwapBalanceHuman)).equal(Number(initialFundingHuman));
    })

    it("start arbitrage", async()=>{
      txArbitrage = await FLASHSWAP.startArbitrage(BASE_TOKEN_ADDRESS, BORROW_AMOUNT); 
      assert(txArbitrage);

      const contractBalancetokenB = await FLASHSWAP.getBalanceOfToken(tokenB);
      const formattedBalancetokenB = Number(ethers.utils.formatUnits(contractBalancetokenB, DECIMALS));
      console.log("Balance of tokenB: " + formattedBalancetokenB);

      const contractBalancetokenC = await FLASHSWAP.getBalanceOfToken(tokenC);
      const formattedBalancetokenC = Number(ethers.utils.formatUnits(contractBalancetokenC, DECIMALS));
      console.log("Balance of tokenC:" + formattedBalancetokenC);
    });
  });
});