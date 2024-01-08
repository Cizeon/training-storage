// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/Storage.sol";

/// @title A contract for testing
/// @author Cizeon
/// @notice Base contract for tests.
/// @dev Default settings are set here.
contract BaseSetupTest is Test {
    Storage internal storageContract;

    struct MyStruct {
        uint16 a;
        uint16 b;
        uint256 c;
    }

    function setUp() public virtual {
        storageContract = new Storage();
    }
}

/// @title A contract for testing the storage contract.
/// @author Cizeon
/// @notice Verifies that the proper value were changed.
contract StorageTest is BaseSetupTest {
    /// @dev test variable value
    function test_testWriteValue() public {
        storageContract.testWriteValue();
        assertEq(storageContract.value(), 0x41);
    }

    /// @dev test variable myMapping
    function test_testWriteMyMapping() public {
        storageContract.testWriteMyMapping();
        assertEq(storageContract.myMapping(0), 0x51);
        assertEq(storageContract.myMapping(1), 0x52);
    }

    /// @dev test variable myDoubleMapping
    function test_testWriteDoubleMapping() public {
        storageContract.testWriteDoubleMapping();
        assertEq(storageContract.myDoubleMapping(0, 0), 0x61);
    }

    /// @dev test variable myArray
    function test_testWriteMyArray() public {
        storageContract.testWriteMyArray();
        assertEq(storageContract.myArray(0), 0x71);
        assertEq(storageContract.myArray(1), 0x72);
        assertEq(storageContract.myArray(2), 0x73);
        assertEq(storageContract.myArray(3), 0x74);

        vm.expectRevert();
        storageContract.myArray(4);
    }

    /// @dev test variable testWriteFarAwayStruct
    function test_testWriteFarAwayStruct() public {
        storageContract.testWriteFarAwayStruct();
        (uint16 a, uint16 b, uint256 c) = storageContract.myDoubleMappingWithStruct(4, 1);
        assertEq(a, 0x81);
        assertEq(b, 0x82);
        assertEq(c, 0x83);
    }

    /// @dev test read variable myFixedSizedArray[2]
    function test_testReadMyFixedSizedArray() public {
        assertEq(storageContract.testReadMyFixedSizedArray(), 0x91);
        assertEq(storageContract.testReadMyFixedSizedArray(), storageContract.myFixedSizedArray(2));
    }
}
