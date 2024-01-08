// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "forge-std/console2.sol";

/// @title A contract to explore storage
/// @author Cizeon
/// @notice This contract was written for a course on Solidity and storage.
/// @dev Please, use this contract to experiment with storage and slot computation.
contract Storage {
    /// @dev This is only the declaration of the struct. It does not use a slot.
    struct MyStruct {
        uint16 a;
        uint16 b;
        uint256 c;
    }
    /// @dev These variables are all going to be set using sstore and the proper slot number.
    uint256 public value; /// @dev Slot 0
    mapping(uint256 => uint256) public myMapping; /// @dev Slot 1
    mapping(uint256 => mapping(uint256 => uint256)) public myDoubleMapping; /// @dev Slot 2
    uint256[] public myArray; /// @dev Slot 3
    mapping(uint => mapping(uint => MyStruct)) public myDoubleMappingWithStruct; /// @dev Slot 4
    uint256[8] public myFixedSizedArray; /// @dev Slot 5

    constructor() {
        // Setting the value for testReadMyFixedSizedArray().
        myFixedSizedArray[2] = 0x91;
    }

    /// @notice This function is used to write to directly the contract's storage instead of using the variables name.
    /// @dev You need to compute the slot number yourself.
    /// @param _slotNumber The slot number where to write.
    /// @param _data The data to write. Don't forget to cast if needed.
    function write(uint256 _slotNumber, bytes32 _data) public {
        assembly {
            sstore(_slotNumber, _data)
        }
    }

    /// @notice This function is used to read directly from contract's storage instead of using the variables name.
    /// @dev You need to compute the slot number yourself.
    /// @param _slotNumber The slot number where to write.
    /// @return data The data read. Don't forget to cast if needed.
    function read(uint256 _slotNumber) public view returns (bytes32 data) {
        assembly {
            data := sload(_slotNumber)
        }
    }

    /// @notice Overwritting a simple variable.
    /// @dev This functions overwrite variable value with 0x41.
    function testWriteValue() external {
        uint256 valueSlotNumber = 0; // value is at slot 0.
        write(valueSlotNumber, 0x0000000000000000000000000000000000000000000000000000000000000041);
    }

    /// @notice Overwritting a simple mapping.
    /// @dev This functions overwrites variable myMapping[0] with 0x51.
    /// @dev This functions overwrites variable myMapping[1] with 0x52.
    function testWriteMyMapping() external {
        uint256 mappingSlotNumber = 1; // myMapping is at slot 1.
        // The mapping slot is the hash of the mapping key and the mapping slot number concatenated.
        uint256 i = uint256(keccak256(abi.encode(0, mappingSlotNumber)));
        console2.log("myMapping[0] slot number:");
        console2.logBytes32(bytes32(i));
        write(i, 0x0000000000000000000000000000000000000000000000000000000000000051);
        i = uint256(keccak256(abi.encode(1, mappingSlotNumber)));
        console2.log("myMapping[1] slot number:");
        console2.logBytes32(bytes32(i));
        write(i, 0x0000000000000000000000000000000000000000000000000000000000000052);
    }

    /// @notice Overwritting a double mapping.
    /// @dev This functions overwrites variable myDoubleMapping[0][0] with 0x61.
    function testWriteDoubleMapping() external {
        uint256 mappingSlotNumber = 2; // myDoubleMapping is at slot 2.
        // First we need compute the slot number for myDoubleMapping[0].
        uint256 ndMappingSlotNumber = uint256(keccak256(abi.encode(0, mappingSlotNumber)));
        // Then we can use myDoubleMapping[0] slot number to compute the final slot.
        uint256 i = uint256(keccak256(abi.encode(0, ndMappingSlotNumber)));
        console2.log("myDoubleMapping[0][0][0] slot number:");
        console2.logBytes32(bytes32(i));
        write(i, 0x0000000000000000000000000000000000000000000000000000000000000061);
    }

    /// @notice Overwritting a dynamic array.
    /// @dev Dynamic array length is set to 4.
    /// @dev This functions overwrites variable myArray[0] with 0x71.
    /// @dev This functions overwrites variable myArray[1] with 0x72.
    /// @dev This functions overwrites variable myArray[2] with 0x73.
    /// @dev This functions overwrites variable myArray[3] with 0x74.
    /// @dev Reading beyond the array, myArray[4] for example should revert.
    function testWriteMyArray() external {
        uint256 arraySlotNumber = 3; // myArray is at slot 3.
        uint256 arrayLength = 4; // Desired length is 4.
        write(arraySlotNumber, bytes32(arrayLength));
        uint256 i = uint256(keccak256(abi.encode(arraySlotNumber)));

        // Writing at myArray + index.
        write(i + 0, 0x0000000000000000000000000000000000000000000000000000000000000071);
        write(i + 1, 0x0000000000000000000000000000000000000000000000000000000000000072);
        write(i + 2, 0x0000000000000000000000000000000000000000000000000000000000000073);
        write(i + 3, 0x0000000000000000000000000000000000000000000000000000000000000074);

        // Overflow - Will revert when trying to read myArray[4].
        write(i + 4, 0x0000000000000000000000000000000000000000000000000000000000000075);
    }

    /// @notice Overwritting a structure from a double mapping.
    /// @dev This functions overwrites variable myDoubleMappingWithStruct[4][1].c with 0x81.
    function testWriteFarAwayStruct() external {
        uint256 mappingSlotNumber = 4; // myDoubleMappingWithStruct is at slot 4.
        // First we need compute the slot number for myDoubleMappingWithStruct[4].
        uint256 ndMappingSlotNumber = uint256(keccak256(abi.encode(4, mappingSlotNumber)));
        // Then myDoubleMappingWithStruct[4][1]
        uint256 i = uint256(keccak256(abi.encode(1, ndMappingSlotNumber)));

        // MyStruct.a and MyStruct.b are on the same slot. We need to do the maths ourselves.
        console2.log("myDoubleMappingWithStruct[4][1].a slot number:");
        console2.logBytes32(bytes32(i));
        uint256 slot0 = 0x81;
        // MyStruct.b is 16 bits after MyStruct.a
        slot0 |= 0x82 << 16;
        write(i, bytes32(slot0));

        // Lastly, the slot final slot number is one slot after as MyStruct.a and MyStruct.b take one slot.
        i += 1;
        console2.log("myDoubleMappingWithStruct[4][1].c slot number:");
        console2.logBytes32(bytes32(i));
        write(i, 0x0000000000000000000000000000000000000000000000000000000000000083);
    }

    /// @notice Reading from a fixed size array.
    /// @dev The value was set from the constructor.
    function testReadMyFixedSizedArray() external view returns (uint256) {
        uint256 mappingSlotNumber = 5 + 2; // myFixedSizedArray is at slot 5, index is 2.
        return uint256(read(mappingSlotNumber));
    }
}
