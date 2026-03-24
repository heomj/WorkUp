package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class BudgetLogVO {


    private int logNo;
    private int bgtMCd;
    private int bgtCd;
    private String bgtChgSe;
    private int bgtChgAmt;
    private String bgtChgRsn; //로그 내용
    private int empId;

    //사원 이름
    private String empNm;

    private Date bgtChgDt;
    private int aprvNo;

    private String aprvTtl; //전자결재 제목



    // 검색 을 위한 변수

    // 회계연도
    private int bgtYr;

    //페이지 번호
    private int currentPage;

    //부서 번호
    private int deptFilter;
    private int deptCd;


    private String deptNm; // 부서 이름
    private String bgtItmNm;//비목명


    //검색 모드
    private String mode;

    //검색어
    private String keyword;

    private String url; //요청URL


}
