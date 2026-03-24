package kr.or.ddit.vo;

import java.util.Date;
import lombok.Data;

@Data
public class ChatUserVO {
    private int chatRmNo;         // 채팅방고유번호 (Composite PK)
    private int empId;            // 사번 (Composite PK / FK)
    private String chatUserNm;    // 채팅자이름
    private String chatUserAuth;  // 채팅자권한 (방장_일반)
    private Date chatUserBgngDt;  // 채팅자입장시간
    private Date chatUserEndDt;   // 채팅자퇴장시간
    private String chatRmType;	  // "1" 이면 1:1, "2" 이면 그룹
    
    // 사원 정보 조인용 (프로필 사진 등을 띄우기 위함)
    private String empNm;         // 사원명
    private String empProfile;    // 프로필 이미지 파일명
    
    private String empJbgd; // 직급 (예: 주임, 사원)
    private String deptNm;  // 부서명 (예: 개발1팀)
}