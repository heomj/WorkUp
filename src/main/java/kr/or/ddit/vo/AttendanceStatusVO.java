package kr.or.ddit.vo;

import lombok.Data;

@Data
public class AttendanceStatusVO {
    private int attSttsId;
    private int empId;
    private int attVacDt;
    private int attMon;
    private int attMonTime;
    private int attLateCt;
    private int attMonBztrp;
}
