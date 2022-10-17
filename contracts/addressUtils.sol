//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

library AddressUtils {
    function isContract(address _addr)
        internal
        view
        returns (bool addressCheck)
    {
        uint256 size;

        assembly {
            size := extcodesize(_addr)
        } // solhint-disable-line
        addressCheck = size > 0;
    }
}
