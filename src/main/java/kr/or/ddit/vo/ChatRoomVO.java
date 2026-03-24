package kr.or.ddit.vo;

import java.util.Date;
import java.util.List;
import lombok.Data;

@Data
public class ChatRoomVO {
    private int chatRmNo;         // 채팅방고유번호 (PK)
    private String chatRmTtl;     // 채팅방제목
    private String chatRmType;    // 채팅방타입 (공통상세코드)
    private String chatRmLastMsg; // 최근메시지
    private Date chatRmBgngDt;    // 채팅방생성일
    private Date chatRmEndDt;     // 채팅방삭제일
    private String chatRmYn;      // 채팅방상태 (Y/N)
    private int empId;
    
    // 조인용 필드
    private List<ChatUserVO> chatUserList; // 채팅 참여자 목록
    private int userCount;                 // 현재 참여 인원수


    // [프로젝트에서 1:1 채팅용]
    private int targetId;
}