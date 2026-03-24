package kr.or.ddit.service.project.impl;

import kr.or.ddit.mapper.project.MyProjectMapper;
import kr.or.ddit.mapper.project.MyWorkMapper;
import kr.or.ddit.service.project.MyProjectService;
import kr.or.ddit.service.project.MyWorkService;
import kr.or.ddit.vo.project.ProjectVO;
import kr.or.ddit.vo.project.PrtpntVO;
import kr.or.ddit.vo.project.TaskVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
public class MyProjectServiceImpl implements MyProjectService {
    @Autowired
    MyProjectMapper myProjectMapper;

    // 리스트 불러오기 (내가 속한 프로젝트)
    @Override
    public List<ProjectVO> getMyProjectList(int empId) {
        List<ProjectVO> projectVOList = this.myProjectMapper.getMyProjectList(empId);

        for(ProjectVO projectVO : projectVOList) {
            List<PrtpntVO> prtpntVOList = this.myProjectMapper.getPrtpntFromProjNo(projectVO.getProjNo());
            projectVO.setPrtpntVOList(prtpntVOList);
            log.info("prtpntVOList:{}",prtpntVOList);
        }

        return projectVOList;
    }

    @Override
    public ProjectVO getProjectByNo(int projNo) {
        //프로젝트에 넣을 Task 가져오기
        List<TaskVO> taskVOList = this.myProjectMapper.getTasksByNo(projNo);
        //프로젝트 정보 가져오기
        ProjectVO projectVO = this.myProjectMapper.getProjectByNo(projNo);
        projectVO.setTaskVOList(taskVOList);
        return projectVO;
    }
}
