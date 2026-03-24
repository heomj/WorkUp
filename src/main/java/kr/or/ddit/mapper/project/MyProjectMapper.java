package kr.or.ddit.mapper.project;

import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.PrtpntVO;
import kr.or.ddit.vo.project.TaskVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MyProjectMapper {
    // 리스트 불러오기 (내가 속한 프로젝트)
    List<ProjectVO> getMyProjectList(int empId);

    List<PrtpntVO> getPrtpntFromProjNo(int projNo);


        //프로젝트에 넣을 Task 가져오기
    List<TaskVO> getTasksByNo(int projNo);
        //프로젝트 정보 가져오기
    ProjectVO getProjectByNo(int projNo);

    //[배치] 프로젝트 : 업데이트 처리할 projNo 가져오기
    List<Integer> getDelayedProjectIds();
    //[배치] 프로젝트 : 위의 애들 처리하기
    int updateDelayedProjects();
    //[배치] 프로젝트 : 업데이트 처리할 리더 empId 가져오기
    List<Integer> getDelayedProjectempIds();

    //[배치] Read Tasks
    TaskVO getDelayedTasks();
    //[배치] Write Tasks
    int updateDelayedTasks(TaskVO task);
}
