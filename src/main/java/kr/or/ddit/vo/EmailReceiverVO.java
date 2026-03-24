package kr.or.ddit.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;

@Data
public class EmailReceiverVO {
    private String emlRcptnYn;
    private String emlImptYn;
    private int emlCategory;
    private String emlStts;
    private String emlDelYn;
    private String emlDelPmntYn;
    private int emlBoxNo;
    private int emlRcvrId;
    private int emlNo;
    private int empId;
    private String emlRcvrType;
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Asia/Seoul")
    private Date emlRcvngDt;
    private String empNm; //사원 이름
    private String empProfile;  //보낸 사원의 프로필..
    private String empJbgd;  // 직급(사워, 주임, 대리, 팀장)
    private String deptNm;     // 부서명
}
