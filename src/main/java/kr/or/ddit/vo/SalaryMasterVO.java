package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class SalaryMasterVO {
    private int salId;
    private int empId;
    private String salMonth;
    private int salBasePay;
    private int salOtPay;
    private int salTripPay;
    private int salDeductionTotal;
    private int salNetPay;
    private String salStts;
    private Date salCreatedDt;
    private Date salUpdateDt;

    private String empJbgd; // JOIN으로 가져온 직급

    private String empNm;   // JOIN으로 가져온 이름
    private String deptNm;  // JOIN으로 가져온 부서명
}
