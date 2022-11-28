// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./Math.sol";
import "./safeMath.sol";
import "./UQ112X112.sol";

contract MyCoolPool{

    using SafeMath for uint;

    using UQ112x112 for uint224;

    address public token0;
    address public token1;
    address public lptoken;
    address public owner;
    uint public totalSupply;
    uint public constant MINIMUM_LIQUIDITY = 10**3;

    uint112 public reserve0;
    uint112 public reserve1;

    constructor(address _token0, address _token1,address _lptoken){
        token0 = _token0;
        token1 = _token1;
        lptoken = _lptoken;
        owner = msg.sender;
    }

    // fetch current reserves
    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    // update reserves 
    function _update(uint balance0, uint balance1) private {
        // require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW'); //overflow
        // uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address _token0, address _token1) {
        require(tokenA != tokenB, ' IDENTICAL_ADDRESSES');
        (_token0, _token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(_token0 != address(0), ' ZERO_ADDRESS');
    }

    // minting LP token after adding liquidity
    function mint(address to) internal returns(uint liquidity){
        (uint _reserve0, uint _reserve1) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        // bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            IERC20(lptoken).transferFrom(address(this),address(0), MINIMUM_LIQUIDITY);// permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED');

        IERC20(lptoken).transferFrom(address(this),to,liquidity);

        _update(balance0, balance1);
        // if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
    
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, ' INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // function to fetch liquidity that we need to add for token0 and token1
    function _addLiquidity(
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        (uint reserveA, uint reserveB) = getReserves();
        if (reserveA == 0 && reserveB == 0) {
            // if this is first transaction for adding liquidity
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
            // checking if amount b is validated for optiomal B
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, 'INSUFFICIENT_B_AMOUNT');
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, 'INSUFFICIENT_A_AMOUNT');
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    // adding liquidity for the current pair
    function addLiquidity(address _token0,address _token1,uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin) external returns (uint amountA, uint amountB, uint liquidity) {
        require(_token0 == token0 && _token1 == token1, "Mismatch pair");
        //updated amount 
        (amountA, amountB) = _addLiquidity(amountADesired, amountBDesired,amountAMin,amountBMin);

        IERC20(_token0).transferFrom(msg.sender,address(this), amountA);
        IERC20(_token1).transferFrom(msg.sender,address(this), amountB);
        (liquidity) = mint(msg.sender); // minting LP tokens for adding liquidity
    }
    

    // we need to send back the user its liquidity that was added before
    function _burn(address to) internal  returns (uint amount0, uint amount1){
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        uint liquidity = IERC20(lptoken).balanceOf(address(this));

        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'INSUFFICIENT_LIQUIDITY_BURNED');

        ERC20Burnable(lptoken).burn(liquidity);
        ERC20(token0).transferFrom(address(this), to, amount0);
         ERC20(token1).transferFrom(address(this), to, amount1);
        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));
        _update(balance0, balance1);
    }


    function withdrawLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to
    ) public returns (uint amountA, uint amountB){
        require(token0 == tokenA && token1 == tokenB, "Mismatch pair");
        //sending back the liquidity
         IERC20(lptoken).transferFrom(msg.sender,address(this), liquidity);
        (uint amount0, uint amount1) = _burn(to);
    
        (address _token0,) = sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == _token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, 'INSUFFICIENT_A_AMOUNT');
        require(amountB >= amountBMin, 'INSUFFICIENT_B_AMOUNT');
    }



    //// swap functionality

    
}