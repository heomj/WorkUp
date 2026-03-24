package kr.or.ddit.vo.project;

import lombok.Data;

@Data
public class TaskParticipantVO {
    private int prtpntNo; // 참여자번호
    private int empId;  // 참여자
    private String prtpntColor; // 색상코드
    private int taskNo; //일감번호

    //추가
    private String empNm; //사원 이름

    // 참여하고 있는 일감수
    private int taskCnt;
}
