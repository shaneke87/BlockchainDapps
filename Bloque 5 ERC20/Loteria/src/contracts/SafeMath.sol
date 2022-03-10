// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.4 <0.7.0;

library SafeMath{
    // Restas
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b<=a, "SafeMath: Subtraction Overflow");
      return a - b;
    }
    
    // Sumas
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
      uint256 c = a + b;
      require(c>=a,"SafeMath: Addition Overflow");
      return c;
    }
    
    // Multiplicacion
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    //Division
    function div(uint a, uint b) internal pure returns(uint256) {
        require(b>a, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    //Modulo
    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b!=0, "SafeMath: modulo by Zero");
        return a%b;
    }
}