// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BaseA {
    function getValue() public virtual pure returns (string memory) {
        return "A";
    }
}

contract BaseB {
    function getValue() public virtual pure returns (string memory) {
        return "B";
    }
}

// Multiple inheritance with function name conflict
contract Combined is BaseB, BaseA {
    // Must specify all contracts being overridden
    function getValue() public override(BaseB, BaseA) pure returns (string memory) {
        return "Combined";
    }
}

// BaseB comes first in the inheritance list but C3 Lineralization goes right to left.
contract TokenX is BaseB, BaseA {
    function getValue() public override(BaseB, BaseA) pure returns (string memory) {
        // This calls BaseA's implementation first
        return super.getValue(); // Returns "A"
    }
}

// BaseA comes first in the inheritance list but C3 Lineralization goes right to left.
contract TokenY is BaseA, BaseB {
    function getValue() public override(BaseA, BaseB) pure returns (string memory) {
        // This calls BaseB's implementation first
        return super.getValue(); // Returns "B"
    }
}
