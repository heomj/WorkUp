package kr.or.ddit.vo.project;

import lombok.Data;

// 프로젝트 참여자 VO
@Data
public class PrtpntVO {
    private int empId; // 프로젝트 참여자ID
    private String prtpntNm;  // 프로젝트 참여자명
    private int projNo;  // 프로젝트 번호
    private String prtpntColor;  // 색상코드





    // [구성원에서 사용]
    private String deptNm;
    private String jbgdNm;

    // 업무 통계 수치 필드
    private int totalTasks;    // 총 업무 수
    private int waitTasks;     // 대기 업무 수
    private int progTasks;     // 진행 업무 수
    private int compTasks;     // 완료 업무 수

    // 총업무 적층형 차트용
    private int imptHigh;
    private int imptNormal;
    private int imptLow;
}
