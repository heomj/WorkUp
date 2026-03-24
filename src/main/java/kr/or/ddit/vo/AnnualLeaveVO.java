package kr.or.ddit.vo;

import lombok.Data;

@Data
public class AnnualLeaveVO {
    private int annLeaveId; //연차번호
    private int empId;  //연차대상
    private int annLeaveTotal;  //총연차
    private int annLeaveUsed;   //사용한 연차
    private int annLeaveRemain; //잔여 연차
    private String annLeaveYear;//기준년도
}
