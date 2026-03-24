package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class ClubMemberVO {

    private int clubMbrNo;
    private int empId; //사번
    private int clubNo;
    private String clubNm;
    private Date clubMbrJoinDt; //가입일
    private Date clubMbrWhdwlDt; //탈퇴일
    private String clubMbrAuth; //직급(회장 or 회원)
    private String clubJoinGret; //가입인사

    //직급
    private String empJbgd;

    //이름
    private String empNm;

    //부서명
    private String deptNm;

    //아바타 이름(저장명)
    private String avtSaveNm;


}
