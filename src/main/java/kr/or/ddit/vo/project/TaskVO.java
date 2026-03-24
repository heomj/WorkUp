package kr.or.ddit.vo.project;

import lombok.Data;

import java.util.Date;
import java.util.List;

@Data
public class TaskVO {
    private int taskNo; //일감번호
    private int projNo; //프로젝트번호
    private int taskUpNo; //상위일감번호
    private int empId; //작성자
    private String taskNm; //작성자 이름
    private String taskTtl; //일감제목
    private String taskCn; //일감내용
    private String taskStts; //일감상태
    private int taskPrgrt; //진행률
    private String taskImpt; //중요도
    private int taskRnk; //우선순위
    private Date taskCrtDt; //일감생성일자
    private Date taskMdfcnDt; //마지막수정일자
    private Date taskActlBgngDt; //실제 일감시작일자
    private Date taskBgngDt; //일감시작 예상일자
    private Date taskEndDt; //일감마감 예상일자
    
    //추가
    private String empNm; //사원 이름

    private ProjectVO projectVO; //상위 프로젝트 resultMap id="projectVO"
    private List<TaskParticipantVO> taskParticipantVOList; //하위일감 resultMap id="taskParticipantVOList"

}
