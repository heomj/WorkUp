package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class AttendanceVO {
    private int attId;
    private int empId;
    private String attStts;
    private Date attCheckIn;
    private Date attCheckOut;
    private Date attWorkDt;
    private String attLateYn;
    private int attDayTime;
    private int attDayMlg;

    private String strCheckIn;  // 추가: 프론트에서 넘어오는 "YYYY-MM-DD HH:mm:ss" 수신용
    private String strCheckOut; // 추가: 프론트에서 넘어오는 "YYYY-MM-DD HH:mm:ss" 수신용

    private String attCheckIn2; // 추가: 디비용 포메팅
    private String attCheckOut2; // 추가: 디비용 포메팅

}
