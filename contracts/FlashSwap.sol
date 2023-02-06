// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.6.6;

import "../node_modules/hardhat/console.sol";
import "./libraries/UniswapV2Library.sol";
import "./libraries/SafeERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IERC20.sol";

contract UniswapCrossFlash{

    using SafeERC20 for IERC20; 

    address private constant UNISWAP_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant SUSHISWAP_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    address private constant SUSHISWAP_ROUTER = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;

    address private constant tokenA = //Place your token address here;
    address private constant tokenB = //Place your token address here; 
    address private constant tokenC = //Place your token address here;

    uint256 private deadline = block.timestamp + 1 days;

    uint256 private constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;

    function fundFlashSwapContract(address _owner, address _token, uint256 _amount) public {
        IERC20(_token).transferFrom(_owner, address(this), _amount);
    }

    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }

   //Place trade
    function placeTrade(address _fromToken, address _toToken, uint256 _amountIn, address factory, address router)private returns (uint256){
        address pair = IUniswapV2Factory(factory).getPair(_fromToken, _toToken); 
        require(pair!=address(0), "Pool does not exist");

        //Perform arbitrage - swap for another token
        address[] memory path = new address[](2);
        path[0] = _fromToken;
        path[1] = _toToken;
        

        uint256 amountRequired = IUniswapV2Router01(router).getAmountsOut(_amountIn, path)[1];
        console.log("amountRequired: ",amountRequired);
 
        uint amountReceived = IUniswapV2Router01(router).swapExactTokensForTokens(
            _amountIn, 
            amountRequired,
            path,
            address(this),
            deadline
        )[1];

        console.log("amountReceived", amountReceived); 
        require(amountReceived>0, "Aborted Tx: Trade returned zero");

        return amountReceived;
    }

    function checkProfitability(uint256 _input, uint256 _output) private pure returns(bool){
        return _output>_input;
    }

    //Function swaps Token B for Token C on Uniswap, then swaps Token C for Token B on SushiSwap
    //Token A is just a placeholder for getPair method to work
    function startArbitrage(address _tokenBorrow, uint256 _amount) external {
        
        IERC20(tokenA).safeApprove(address(UNISWAP_ROUTER), MAX_INT);
        IERC20(tokenB).safeApprove(address(UNISWAP_ROUTER), MAX_INT);
        IERC20(tokenC).safeApprove(address(UNISWAP_ROUTER), MAX_INT);

        IERC20(tokenB).safeApprove(address(SUSHISWAP_ROUTER), MAX_INT);
        IERC20(tokenA).safeApprove(address(SUSHISWAP_ROUTER), MAX_INT);
        IERC20(tokenC).safeApprove(address(SUSHISWAP_ROUTER), MAX_INT);

        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(_tokenBorrow, tokenA);

        require(pair!= address(0),"Pool does not exist");

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        uint amount0Out = _tokenBorrow == token0 ? _amount: 0; 
        uint amount1Out = _tokenBorrow == token1 ? _amount: 0; 

        bytes memory data = abi.encode(_tokenBorrow, _amount, msg.sender); 

        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    //startArbitrage calls this function which executes trade
    function uniswapV2Call(address _sender, uint256 _amount0, uint256 _amount1, bytes calldata _data) external{
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(UNISWAP_FACTORY).getPair(
            token0,
            token1
        );
        require(msg.sender == pair, "The sender needs to match the pair contract");
        require(_sender == address(this), "Sender should match this contract");

        (address tokenBorrow, uint256 amount, address myAddress) = abi.decode(_data, (address, uint256, address));

        uint256 fee = ((amount*3)/997)+1;
        uint256 amountToRepay = amount + fee;

        uint256 loanAmount = _amount0 >0 ? _amount0: _amount1;
         
        uint256 trade1 = placeTrade(tokenB, tokenC, loanAmount, UNISWAP_FACTORY,UNISWAP_ROUTER);
        uint256 trade2 = placeTrade(tokenC, tokenB, trade1, SUSHISWAP_FACTORY, SUSHISWAP_ROUTER);
        bool profCheck = checkProfitability(loanAmount, trade2);
        require(profCheck, "Arbitrage not profitable");

        //PAY YOURSELF FIRST BEFORE PAYING LOAN
        IERC20 otherToken = IERC20(tokenB);
        otherToken.transfer(myAddress, trade2 - amountToRepay);

        //Pay Loan Back 
        IERC20(tokenBorrow).transfer(pair,amountToRepay);
    }

}

  