package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class AlarmReceiveVO {

    private int almRcvrNo;  //알람수신  ID(기본키)
    private int almId;      //알람 ID (조인하는 컬럼)
    private int empId;      //수신자 ID
    private Date almRcvrTm; //수신 시점
    private String almYn;   //확인여부
    private String almYnTm; //확인시점
    private String almDelYn;   //삭제여부
    private String almUrlVar;
    // url 뒤에 붙는 커스텀 변수
    //(따로 지정하지 않으면 null값을 가짐)

}
