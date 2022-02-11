pragma solidity >= 0.4.12 < 0.6.0;

import "./ERC721Full.sol";

contract Color is ERC721Full {
    string [] public colors;
    mapping(string => bool) _colorExists;

    constructor() ERC721Full("Color","COLOR") public {}

    //por ejemplo
    function mint(string memory _color) public {
        require(!_colorExists[_color], "COLOR: El color ya existe en el mapping de colores");
        uint _id = colors.push(_color);
        _mint(msg.sender, _id);
        _colorExists[_color] = true;
    }
}