package kr.or.ddit.mapper.project;

import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskParticipantVO;
import kr.or.ddit.vo.project.TaskVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface KanbanprojectMapper {

    //멘션기능 (@query > query가 포함된 empId 또는 empNm로 EmployeeVO 프로젝트 참가자 찾기>리스트)
    public List<EmployeeVO> findMembersByQuery(@Param("query") String query, @Param("projNo") int projNo);

    //일감 리스트 불러오기
    public List<TaskVO> getTasklist(int projNo);

    //일감 상태 변경
    public int updateTaskStts(TaskVO taskVO);

    //새일감 insert
    public int insertTask(TaskVO taskVO);

    //일감 담당자 insert
    public int insertTaskParticipant(TaskParticipantVO participant);

    //프로젝트 이름 불러오기
    public ProjectVO getProject(int projNo);

    //프로젝트 상태 업데이트(지연, 진행)
    public int updateProjectStatus(@Param("projNo") int projNo, @Param("projStts") String projStts);

    //프로젝트에서 지연 개수 세기
    public int countDelayedTasks(int projNo);

    /**
     * 일감 수정하기(팀장만)
     * @param taskVO 일감 폼 데이터
     * @return update 된 수
     */
    public int updateTask(TaskVO taskVO);


    //일감 담당자 delete
    public int deleteTaskParticipant(int taskNo);


}
