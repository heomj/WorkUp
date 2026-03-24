package kr.or.ddit.service.project;

import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;

import java.util.List;

public interface KanbanprojectService {

    //멘션기능 (@query > query가 포함된 empId 또는 empNm로 EmployeeVO 프로젝트 참가자 찾기 리스트)
    List<EmployeeVO> findMembersByQuery(String query, int projNo);

    //일감 리스트 불러오기
    public List<TaskVO> getTasklist(int projNo);

    //일감 상태 변경
    public int updateTaskStts(TaskVO taskVO);

    //새일감 넣기
    public int insertTask(TaskVO taskVO);

    //프로젝트 이름 불러오기
    public ProjectVO getProject(int projNo);


    /**
     * 일감 수정하기(팀장만)
     * @param taskVO 일감 폼 데이터
     * @return update 된 수
     */
    public int updateTask(TaskVO taskVO);

}
