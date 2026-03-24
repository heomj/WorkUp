package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class OvertimeDocumentVO {
    private int attTypeId;
    private int empId;
    private Date excsWorkDocBgng;
    private Date excsWorkDocEnd;
    private String excsWorkDocRes;
    private String excsWorkAprvYn;
    private String excsWorkStts;
}
