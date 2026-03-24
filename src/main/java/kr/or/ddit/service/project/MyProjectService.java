package kr.or.ddit.service.project;

import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;

import java.util.List;

public interface MyProjectService {
    // 리스트 불러오기 (내가 속한 프로젝트)
    List<ProjectVO> getMyProjectList(int empId);

    ProjectVO getProjectByNo(int projNo);
}
