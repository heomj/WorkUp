package kr.or.ddit.vo;

import lombok.Data;

@Data
public class BudgetDetailVO {

    private int bgtCd; //예산 코드
    private int bgtMCd; //예산마스터 코드
    private String bgtItmNm; //비목명
    private int bgtAmt; //예산
    private int bgtExcn; //사용금액


    // Master 정보
    private String deptCd;
    private String deptNm;    // 조인해서 가져올 부서명
    private int bgtYr;
    private String bgtStts;

    private String bgtDetailStts;

}
