// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IDullNosql} from "./interfaces/IDullNosql.sol";
import {OrderPreservedMapping} from "./OrderPreservedMapping.sol";

contract DullNosql is IDullNosql {
    using OrderPreservedMapping for OrderPreservedMapping.Map;

    struct Collection {
        OrderPreservedMapping.Map[] documents;
    }

    // We can just use mapping(string => IterabledMapping.Map[]) too
    mapping(string => Collection) private collections;

    // if index is 0 it mean create new document, if not it will add/update value for that key
    function addDocument(
        string memory collectionName,
        uint index,
        string memory key,
        uint value
    ) external returns (uint documentIndex) {
        Collection storage collection = collections[collectionName];
        OrderPreservedMapping.Map storage doc;
        if (index == 0) {
            collection.documents.push();
            uint size = collection.documents.length;
            doc = collection.documents[size - 1];
            doc.set(key, value);
            return size;
        }
        require(index <= collection.documents.length, "index has to be less or equal collection's size");
        doc = collection.documents[index - 1];
        doc.set(key, value);
        return index;
    }

    function getDocumentValue(
        string memory collectionName,
        uint index,
        string memory key
    ) external view returns (uint value) {
        Collection storage collection = collections[collectionName];
        require(index <= collection.documents.length, "index has to be less or equal collection's size");
        OrderPreservedMapping.Map storage doc = collection.documents[index - 1];
        value = doc.get(key);
    }

    function getDocumentValues(
        string memory collectionName,
        string memory key
    ) external view returns (uint[] memory) {
        Collection storage collection = collections[collectionName];
        uint256[] memory tmpResult = new uint256[](
            collection.documents.length
        );
        uint256 count;

        for (uint i = 0; i < tmpResult.length; i++) {
            OrderPreservedMapping.Map storage doc = collection.documents[i];
            if (doc.exist[key] == true) {
                tmpResult[count] = doc.get(key);
                count++;
            }
        }

        uint256[] memory result = new uint256[](count);
        for (uint i = 0; i < count; i++) {
            result[i] = tmpResult[i];
        }

        return result;
    }

    function updateDocumentValues(
        string memory collectionName,
        string memory key,
        uint value
    ) external returns (bool updated) {
        Collection storage collection = collections[collectionName];
        for (uint i = 0; i < collection.documents.length; i++) {
            OrderPreservedMapping.Map storage doc = collection.documents[i];
            if (doc.exist[key] == true) {
                doc.set(key, value);
                updated = true;
            }
        }
    }

    function deleteDocumentKeys(
        string memory collectionName,
        string memory key
    ) external returns (bool deleted) {
        Collection storage collection = collections[collectionName];

        for (uint i = 0; i < collection.documents.length; i++) {
            OrderPreservedMapping.Map storage doc = collection.documents[i];
            if (doc.exist[key] == true) {
                uint256 size = doc.keys.length;
                uint256 index = doc.getIndex(key);
                doc.keys[index] = doc.keys[size - 1];
                doc.keys.pop();
                delete doc.data[key];
                delete doc.index[key];
                delete doc.exist[key];
                deleted = true;
            }
        }
    }
}