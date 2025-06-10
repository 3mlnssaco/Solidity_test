//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Struct {
    // 상품 구조체 정의
    struct Product {
        string name;
        uint price;
    }

    // 메인 상품
    Product public mainProduct;
    // 최대 상품 개수
    uint public maxProductCount;

    // 생성자에서 최대 상품 개수 초기화
    constructor() {
        maxProductCount = 1000;
    }

    // 메인 상품을 초기화하는 함수
    function initProduct() public {
        Product memory firstProduct = Product("toy1", 10);
        mainProduct = firstProduct;
    }

    // 메인 상품 정보 설정 함수
    function setMainProduct(string memory _name, uint _price) public {
        mainProduct.name = _name;
        mainProduct.price = _price;
    }

    // 메인 상품 가격 반환 함수
    function getMainProductPrice() public view returns (uint) {
        return mainProduct.price;
    }
}



 