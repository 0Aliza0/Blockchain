pragma solidity 0.4.16;
import "./DateTime.sol";
contract EpochConverter{

    DateTime datetime = new DateTime();


    function getDate(uint timestamp) public view returns(uint16 year , uint8 month , uint8 day){

        year = datetime.getYear(timestamp);
        month = datetime.getMonth(timestamp);
        day = datetime.getDay(timestamp);
    }
    function getTime(uint timestamp) public view returns(uint8 hour , uint8 minute , uint8 second){

        hour = datetime.getHour(timestamp);
        minute = datetime.getMinute(timestamp);
        second = datetime.getSecond(timestamp);
    }
    /*https://epochconverter.com ---> For Test*/
}