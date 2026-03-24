package kr.or.ddit.vo.project;

import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class ProjectVO {
    private int projNo;  // 프로젝트 번호
    private int empId;  // 리더
    private String projNm; // 리더명
    private String projTtl;  // 제목
    private String projDtl;  // 설명
    private Date projBgngDt;  // 시작일
    private Date projEndDt;  // 종료일
    private String projStts;   // 상태(Y/N)

    private String projColor;  // 색상코드
    private String projIpt; // 중요도(별) (Y/N)

    private List<TaskVO> taskVOList; // 하위일감 resultMap id="taskVOList"
    private List<PrtpntVO> prtpntVOList;  // 참여자 사원 List

    private int projPrgrt;  // 프로젝트 진행률
    private int timePrgrt;  // 날짜에 의거한 진행률

    //중요도(별) (Y/N) (참가자 부여)
    private String prtpntProjIpt;


}
