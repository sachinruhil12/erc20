//SPDX LIcense-Identifier:MIT

pragma solidity>=0.6.0 <0.9.0;

interface erc1155{


event TransferSingle(address operator, address from , address to , uint id , uint amount);
event ApprovalForAll( address owner, address operator, bool approved );
event TransferBatch(address operator, address from , address to , uint[] ids , uint[] amounts);


function balanceOf(address owner, uint id) external view returns(uint);
function balanceOfBatch(address[] calldata owners, uint[] calldata ids) external  view returns(uint[] memory);
function setApprovalForAll(address operator, bool approved) external ;
function isApprovalForAll(address owner, address operator) external view returns(bool);
function safeTransferFrom(address from ,address to , uint id , uint amount, bytes calldata data) external;
function safeBatchTransferFrom(address from, address to , uint[] calldata ids, uint[] calldata amounts,bytes calldata data)external;

}

contract ercc1155{

event TransferSingle(address operator, address from , address to , uint id , uint amount);
event ApprovalForAll( address owner, address operator, bool approved );
event TransferBatch(address operator, address from , address to , uint[] ids , uint[] amounts);

mapping(uint=> mapping(address=>uint)) public balances;
mapping(address=>mapping(address=>bool)) public operatorApproval;




function balanceOf(address owner, uint id) external view returns(uint){
    require(owner !=address(0), "not the zero address");
    return balances[id][owner];

}
function balanceOfBatch(address[] calldata owners, uint[] calldata ids) external  view returns(uint[] memory){

require(owners.length == ids.length,"both are mismatch");
uint batchbalances= new  uint[](owners.length);
for(uint i=0; i<owners.length;i++){

batchbalances[i] = balanceOf(owners[i],ids[i]);

}
return batchbalances;
}


function setApprovalForAll(address operator, bool approved) external{

_setApprovalForAll(msg.sender, operator, approved);


}

function _setApprovalForAll(address owner, address operator, bool approved) internal{
require(owner !=operator," setting the approval status");
operatorApproval[owner][operator]=approved;
emit ApprovalForAll(owner, operator, approved);

}


function isApprovalForAll(address owner, address operator) external view returns(bool){
    return operatorApproval[owner][operator];
}
function safeTransferFrom(address from ,address to , uint id , uint amount, bytes calldata data) external{
require(from == msg.sender || isApprovalForAll(from ,msg.sender),"caller is not the token owner bnor approved" );

_safeTransferFrom(from, to , id, amount, data);

}
function safeBatchTransferFrom(address from, address to , uint[] calldata ids, uint[] calldata amounts,bytes calldata data)external{
    require(from == msg.sender || isApprovalForAll(from,msg.sender),"caller is not the token owner nor approved");

_safebatchTransferFrom(from ,to , ids, amounts,data);
}


function _safeTransferFrom(address from, address to , uint id, uint amount, bytes calldata data) internal{
require(from !=address(0),"from is not the zero address");
address operator = msg.sender;
uint[] memory ids = _singletonArray(id);
uint[] memory amounts = _singletonArray(amount);

_beforeTokenTransfer(operator, from , to , id, amount, data);
uint fromBalance = balances[id][from];
require(fromBalance >=amount ,"insufficient balance");
unchecked{
    balances[id][from] = fromBalance - amount;
}
balances[id][to] += amount;
emit TransferSingle(operator, from, to, id, amount);
_afterTokenTransfer(operator, from , to , ids,  amounts, data);
_doSafeTransferAcceptanceCheck(operator,from , to , id, amount,data);
}

function _safebatchTransferFrom(address from, address to , uint[] ids, uint[] amounts, bytes calldata data) internal{
require(ids.length == amounts.length,"both are mismatch");
require(to != address(0),"transfer to zero address");

address operator = msg.sender;
_beforeTokenTransfer(operator, from, to , ids, amounts, data);
for(uint i =0; i <ids.length;i++){
uint id = ids[i];
uint amount = amounts[i];
uint fromBalance = balances[id][from];

require(fromBalance >= amount,"insufficient balance");

unchecked{

balances[id][from] = fromBalance-amount;
}
balances[id][from] += amount;
emit TransferBatch(operator, from , to ,ids, amounts);
_afterTokenTransfer(operator, from, to , ids, amounts, data);
_doSafeBatchTransferAcceptanceCheck(operator, from, to , ids, amounts,  data);
}
}

function _mint(address to , uint amount, bytes calldata data) internal{

require(to !=address(0), "address is not the owner");
address operator = msg.sender;
uint[]  ids = _sngletonArray(id);
uint[] amounts = _singletonArray(amount);
_beforeTokenTransfer(operator, address(0),to, ids, amounts, data);
emit TransferSingle(operator,address(0),to, id, amount);
_afterTokenTransfer(operator, address(0), to, ids, amounts, data);
_doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);

}

function _mintBatch(address to ,uint[] ids, uint[] amounts, bytes calldata data) internal{

require(to != address(0),"address is not the zero address");
require(ids.length == amounts.length,"both are mismatch");

address operator = msg.sender;

_beforeTokenTransfer(operator, address(0),ids, amounts, data);
for(uint i =0; i<ids.length; i++){

balances[ids][i][to] +=amounts[i];
}
emit TransferBatch(operator, address(0), to, ids, amounts);
_afterTokenTransfer(operator, address(0), to , ids, amounts,data);
_doSafeBatchAcceptanceCheck(operator, address(0),to , ids, amounts,data);
}

function _afterTokenTransfer(address operator, address from, address to , uint[] ids, uint[] amounts,bytes calldata data)internal{}
function _beforeTokenTransfer(address operator, address from , address to , uint amount, bytes calldata data)internal{}
 function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }


    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _singletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }



}










