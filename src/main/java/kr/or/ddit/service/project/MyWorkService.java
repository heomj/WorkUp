package kr.or.ddit.service.project;

import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;

import java.util.List;

public interface MyWorkService {
    // 사원의 프로젝트 리스트
    public List<ProjectVO> toMyWorkList(int empId);

    // 일감 업데이트
    public int updateTask(TaskVO taskVO);
}
