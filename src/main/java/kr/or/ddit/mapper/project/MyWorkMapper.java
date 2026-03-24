package kr.or.ddit.mapper.project;

import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.TaskVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MyWorkMapper {
    // 사원의 프로젝트 리스트
    public List<ProjectVO> toMyWorkList(int empId);

    // 일감 업데이트
    public int updateTask(TaskVO taskVO);
}
