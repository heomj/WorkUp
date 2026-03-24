package kr.or.ddit.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;

@Data
public class AprvLineVO {

    private int aprvLnNo;      // 결재 라인 번호 (PK)
    private int aprvNo;        // 결재 번호 (FK, NOT NULL)
    private int aprvLnLvl;  // 결재 단계/레벨
    private int empId;         // 결재자 사원 ID (NOT NULL)
    private String aprvLnStts;  // 결재 라인 상태(코드)

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date aprvLnDt;      // 결재 처리 일시
    private String aprvLnCn;    // 결재 의견/반려 사유 (VARCHAR2 500자)

    private int aprvId; //결재자 아이디
    private String aprvNm; //결재자 이름
    private String empJbgd; //결재자 직급

    private String empSign; //결재사인 이미지
    private String empProfile; //결재자 프로필

    private String docUpdateStts; //회수하거나,


    //상세문서 번호..
    private int aprvDocNo;

    //문서 종류...
    private String aprvSe;

    //근태문서인지 여부 확인하기
    private String isAttDoc;

    //휴가 여부 확인하기
    private String isVctDoc;
    //휴가 종류도 받기
    private String vctDocCd;
    //휴가 사용일수도 받기..
    private int vctUsedDays;

    // 결재자 부서명
    private String deptNm;


    //실제 휴가 사용일...(DB랑 맞춘 VO 변수)
    private double vctTotalDays; //휴가 사용일

    //휴가 사용자도..(문서작성자)
    private int docWriterId;

}
