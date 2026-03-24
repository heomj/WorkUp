package kr.or.ddit.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import java.util.Date;
import java.util.List;


@Data
public class SurveyVO {
    // 설문
    private int srvyNo;         // 설문 번호
    private int srvyEmpId;      // 설문 작성자
    private String srvyCn;      // 설문 내용
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date srvyBgngDt;    // 설문 시작일
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date srvyEndDt;     // 설문 종료일
    private String srvyStts;    // 설문 진행 상태
    private int srvyNope;       // 설문지 참여자 수
    private String srvyAnon;    // 익명 여부
    private String srvyTtl;     // 설문 설명
    private int srvyMlg;     // 설문 마일리지

    private List<SurveyVO> questions;
    private List<SurveyVO> items;


    // 설문 대상자관리
    private int empId;          // 설문 작성자 ID
    private String srvyYn;      // 설문참여여부
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date srvyDt;        // 설문 참여시점


    // 설문 문항
    private int srvyQuestNo;    // 문항 번호
    private String srvyQuestCn; // 문항 내용
    private int srvyQuestType;  // 문항 유형
    private int srvyQuestOrd;   // 문항 순서

    // 설문 문항보기
    private int srvyQuestItemNo;        // 보기 번호
    private String srvyQuestItemCn;     // 보기 내용


    // 설문 답변
    private int srvyAnsNo;              // 답변 번호
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date srvyAnsDt;             // 답변 일시
    private String srvyAnsCn;



    // [사용자 설문 통계]
    private int itemCount;         // 객관식: 각 항목별 선택 수
    private List<String> answers;  // 주관식: 답변 텍스트 리스트


    // [관리자 통계]
    private double aveData;     // 평균 참여율
    private int total;          // 전체 설문 수
    private int ongoing;        // 진행 중 설문 수
    private int monthlyNew;     // 이달의 신규 설문 수
    private int totalEmpCount;  // 재직 중인 전체 사원 수

}
