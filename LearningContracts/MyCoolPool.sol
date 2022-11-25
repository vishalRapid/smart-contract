// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Math.sol";
import "./safeMath.sol";
import "./UQ112X112.sol";

contract MyCoolPool {
    using SafeMath for uint256;

    using UQ112x112 for uint224;

    address public token0;
    address public token1;
    address public lptoken;
    address public owner;
    uint256 public totalSupply;
    uint256 public constant MINIMUM_LIQUIDITY = 10**3;

    uint112 public reserve0;
    uint112 public reserve1;

    constructor(
        address _token0,
        address _token1,
        address _lptoken
    ) {
        token0 = _token0;
        token1 = _token1;
        lptoken = _lptoken;
        owner = msg.sender;
    }

    // fetch current reserves
    function getReserves()
        public
        view
        returns (uint112 _reserve0, uint112 _reserve1)
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    // update reserves
    function _update(uint256 balance0, uint256 balance1) private {
        // require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'UniswapV2: OVERFLOW'); //overflow
        // uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    // minting LP token after adding liquidity
    function mint(address to) internal returns (uint256 liquidity) {
        (uint256 _reserve0, uint256 _reserve1) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0.sub(_reserve0);
        uint256 amount1 = balance1.sub(_reserve1);

        // bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            IERC20(lptoken).transferFrom(
                address(this),
                address(0),
                MINIMUM_LIQUIDITY
            ); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                amount0.mul(_totalSupply) / _reserve0,
                amount1.mul(_totalSupply) / _reserve1
            );
        }
        require(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");

        IERC20(lptoken).transferFrom(address(this), to, liquidity);

        _update(balance0, balance1);
        // if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, " INSUFFICIENT_AMOUNT");
        require(reserveA > 0 && reserveB > 0, "INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // function to fetch liquidity that we need to add for token0 and token1
    function _addLiquidity(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        (uint256 reserveA, uint256 reserveB) = getReserves();
        if (reserveA == 0 && reserveB == 0) {
            // if this is first transaction for adding liquidity
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = quote(amountADesired, reserveA, reserveB);
            // checking if amount b is validated for optiomal B
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    // adding liquidity for the current pair
    function addLiquidity(
        address _token0,
        address _token1,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        require(_token0 == token0 && _token1 == token1, "Mismatch pair");
        //updated amount
        (amountA, amountB) = _addLiquidity(
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );

        IERC20(_token0).transferFrom(msg.sender, address(this), amountA);
        IERC20(_token1).transferFrom(msg.sender, address(this), amountB);
        (liquidity) = mint(msg.sender); // minting LP tokens for adding liquidity
    }
}
