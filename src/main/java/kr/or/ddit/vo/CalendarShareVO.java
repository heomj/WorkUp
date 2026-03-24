package kr.or.ddit.vo;

import lombok.Data;

@Data
public class CalendarShareVO {

    private int calShareNo;			// 캘린더 번호
    private int deptCd;				// 부서 코드
    private int calShareCd;			// 공유 번호
    private int calShareId;			// 사번
    private String calShareType;	// 공유 대상 구분
    private String calShareDate;	// 일정 공유일
    private String calShareNm;
    private String calShareDeptNm;
    private int calLvl;

}
