package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;
@Data
public class AttendanceOutVO {
    private int attOutId;
    private int empId;
    private Date attOutStartDt;
    private Date attOutEndDt;
    private String attOutRsn;
    private String attOutTime;

    private String strOutStart;  // 추가: 프론트에서 넘어오는 "YYYY-MM-DD HH:mm:ss" 수신용
    private String strOutEnd; // 추가: 프론트에서 넘어오는 "YYYY-MM-DD HH:mm:ss" 수신용

    private String attOutStartDt2; //포멧팅
    private String attOutEndDt2; //포멧팅

}
