package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class TripDocumentVO {
    private int attTypeId;
    private int empId;
    private String bztrpPlc;
    private Date bztrpStart;
    private Date bztrpEnd;
    private int bztrpTotalDays;
    private String bztrpRsn;
    private String bztrpAprvYn;
    private String bztrpStts;
}
