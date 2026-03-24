package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class ClubVO {

    private int clubNo;
    private int clubNope;
    private String clubNm;
    private String clubCn;
    private Date clubBgngDt;

    //개설일 날짜만
    private String createDt;



    private Date clubEndDt;
    private String clubStts;


    // 관리자 ----------------------------

    //회장명
    private String presidentNm;

    //회원수
    private int memberTotalCnt; //전체
    private int memberActiveCnt; //활동
    private int memberWhdwlCnt; //탈퇴



    //공지사항 수
    private int noticeTotalCnt; //전체
    private int noticeActiveCnt; //정상
    private int noticeDelCnt; //삭제
    //갤러리 수
    private int galleryTotalCnt; //전체
    private int galleryActiveCnt; //정상
    private int galleryDelCnt; //삭제










}
