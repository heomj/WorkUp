package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class ClubNoticeVO {

    private int rnum;

    private int clubNtcNo;
    private int clubNo;
    private int empId; //작성자 사번..
    private int deptCd; //부서 코드
    private String clubNtcTtl; //제목
    private String clubNtcCn; //내용
    private String clubNm; //동호회 이름
    private int clubNtcCnt; //조회수
    private Date clubNtcDt; //작성일
    private String clubNtcStts; // 상태(삭제여부..)

    //아바타 이름(저장명)
    private String avtSaveNm;

    //직급
    private String empJbgd;
    //이름
    private String empNm;
    //부서명
    private String deptNm;


    //페이지 번호
    private int currentPage;

    //검색 모드
    private String mode;

    //검색어
    private String keyword;

    private String url; //요청URL





}
