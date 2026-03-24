package kr.or.ddit.vo;

import java.util.Date;
import lombok.Data;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
@Data
public class ChatLogVO {
    private long chatLogNo;    // 채팅대화순번 (PK)
    private int chatRmNo;      // 채팅방고유번호 (FK)
    private int empId;         // 채팅작성자 (사번)
    private String chatCn;     // 채팅내용
    private Date chatDt;       // 작성시점
    private String chatType; // 🌟 새로 추가된 필드 (TEXT, IMAGE, FILE 중 하나가 담김)
    
    // 화면 표시용 필드
    private String empNm;      // 작성자 이름
    private String empProfile; // 작성자 프로필 이미지
    
    private Long fileId;		// 파일 아이디
    private Long fileDtlId;     // ◀ 추가: FILE_DETAIL의 PK (실제 다운로드용 ID)
    private String fileName;	// 파일의 원래 이름
}