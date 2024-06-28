// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library OrderPreservedMapping {
    // a map type
    struct Map {
        string[] keys;
        mapping(string => uint256) data;
        mapping(string => bool) exist;
        mapping(string => uint256) index;
    }

    // set a value in the map
    function set(Map storage map, string memory key, uint256 val) public {
        if (map.exist[key] == false) {
            map.keys.push(key);
            map.index[key] = map.keys.length - 1;
            map.exist[key] = true;
        }
        map.data[key] = val;
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    // get a value from the map
    function get(Map storage map, string memory key) public view returns (uint256) {
        return map.data[key];
    }

    function getIndex(Map storage map, string memory key) public view returns (uint256) {
        return map.index[key];
    }

    // list all values in the map ordered by insertion
    function listValues(Map storage map) public view returns (uint256[] memory) {
        uint len = map.keys.length;
        uint256[] memory results = new uint256[](len);
        for (uint i = 0; i < len; i++) {
            string memory tmp_str = map.keys[i];
            uint256 value = get(map, tmp_str);
            results[i] = value;
        }
        return results;
    }
}

contract UseOrderPreservedMapping {
    using OrderPreservedMapping for OrderPreservedMapping.Map;
    OrderPreservedMapping.Map map;

    function setValue(string memory key, uint256 value) public {
        map.set(key, value);
    }

    function getValue(string memory key) public view returns (uint256) {
        return map.get(key);
    }
}
