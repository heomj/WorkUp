package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class VacationDocumentVO {
    private int attTypeId;
    private int empId;
    private String vctDocCd;
    private Date vctDocBgng;
    private Date vctDocEnd;
    private double vctTotalDays; //휴가 사용일
    private String vctDocRsn;
    private String vctAprvYn;
    private String vctStts;
}
